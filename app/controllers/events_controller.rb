class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authorize_owner_or_admin!, only: %i[edit update destroy]

  def landing
    #just renders landing page with form
  end

  # GET /events
  def index
    Rails.logger.info "🔍 EVENTS INDEX HIT - User-Agent: #{request.user_agent}"
    Rails.logger.info "🔍 REQUEST PARAMS: #{params.inspect}"

    # Require location parameters for search
    if params[:address].blank? && params[:lat].blank?
      Rails.logger.info "❌ No location parameters provided, redirecting to landing"
      redirect_to events_landing_path, alert: "Please enter a location to search for events."
      return
    end

    # Your existing index logic...
    if params[:address].present? || params[:lat].present?
      @events = find_nearby_events
      @search_params = extract_search_params
    else
      @events = []
      @search_params = nil
    end

    # Handle error cases - don't apply date filter if there's an error
    if @error_message || @no_results_message
      @events = []
    else
      @events = apply_date_range_filter(@events)
    end

    respond_to do |format|
      format.html
      format.json { render json: @events }
      format.turbo_stream { render :index }
    end
  end

  # GET /events/nearby - New filtered endpoint
  def nearby
    Rails.logger.info "🔍 NEARBY ENDPOINT HIT with params: #{params.inspect}"

    @events = find_nearby_events
    @search_params = extract_search_params

    # Apply date range filter
    @events = apply_date_range_filter(@events)

    Rails.logger.info "📊 Found #{@events.count} events after filtering"
    Rails.logger.info "🎯 Search params: #{@search_params}"

    respond_to do |format|
      format.html { render :index }
      format.json { render :nearby }
    end
  end

  # GET /events/1
  def show
    @event = Event.find(params[:id])
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    # Check for venue verification if an artist is creating the event
    if artist_signed_in? && params[:venue_verification] != "1"
      @event = Event.new(event_params)
      flash.now[:alert] = "Please verify that the venue information is correct before creating the event."
      render :new, status: :unprocessable_entity
      return
    end

    # Check for artist verification ONLY if an owner is creating the event AND an artist_id is provided
    if owner_signed_in? && params[:event][:artist_id].present? && params[:artist_verification] != "1"
      @event = Event.new(event_params)
      flash.now[:alert] = "Please verify that the artist information is correct before creating the event."
      render :new, status: :unprocessable_entity
      return
    end

    # Check for manual artist confirmation ONLY if owner is creating event with manual artist_name
    if owner_signed_in? && params[:event][:artist_name].present? && params[:event][:artist_id].blank? && params[:manual_artist_confirmation] != "1"
      @event = Event.new(event_params)
      flash.now[:alert] = "Please confirm that you searched for the artist and they're not in our database."
      render :new, status: :unprocessable_entity
      return
    end

    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        # Redirect based on who created the event
        if artist_signed_in?
          format.html { redirect_to artist_dashboard_path(current_artist), notice: "Event was successfully created." }
        elsif owner_signed_in?
          format.html { redirect_to owner_dashboard_path(current_owner), notice: "Event was successfully created." }
        else
          format.html { redirect_to @event, notice: "Event was successfully created." }
        end
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end

    # Send notifications after successful save
    send_event_notifications(@event)
  end

  # PATCH/PUT /events/1
  def update
    respond_to do |format|      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy!

    respond_to do |format|
      format.html {
        if artist_signed_in?
          redirect_to artist_dashboard_path(current_artist), status: :see_other, notice: "Event has been cancelled successfully."
        elsif owner_signed_in?
          redirect_to owner_dashboard_path(current_owner), status: :see_other, notice: "Event has been cancelled successfully."
        else
          redirect_to events_path, status: :see_other, notice: "Event has been cancelled successfully."
        end
      }
    end
  end

  def map
    # Geocode if lat/lng missing but address is provided
    if params[:lat].blank? || params[:lng].blank?
      if params[:address].present?
        coords = geocode_address(params[:address])
        if coords
          params[:lat] = coords[0]
          params[:lng] = coords[1]
        else
          flash[:alert] = "Could not locate address"
          redirect_to map_path and return
        end
      end
    end

    @center_lat = params[:lat]&.to_f
    @center_lng = params[:lng]&.to_f
    @selected_venue_id = params[:venue_id]&.to_i

    if @center_lat && @center_lng
      radius = search_radius
      @events = Event.upcoming
                     .includes(:venue, :artist)
                     .where(venue_id: Venue.near([@center_lat, @center_lng], radius, units: :mi, order: false).pluck(:id))

      # Apply date range filter
      @events = apply_date_range_filter(@events)
    else
      @events = []
    end

    respond_to do |format|
      format.json # renders map.json.jbuilder
      format.html
    end
  end

  def map_landing
    if params[:lat].present? && params[:lng].present?
      redirect_to events_map_path(
        lat: params[:lat],
        lng: params[:lng],
        address: params[:address],
        radius: params[:radius],
        date_range: params[:date_range],
      )
    end
  end

  private

  def send_event_notifications(event)
    # Only send notifications if the event has a database artist (not manual artist_name)
    return unless event.artist.present?

    # Notify artist's followers (now includes Users, Owners, and Artists)
    followers = event.artist.followers
    NewEventNotifier.with(event: event).deliver(followers) if followers.any?

    # Notify venue's followers (now includes Users, Owners, and Artists)
    followers = event.venue.followers
    NewVenueEventNotifier.with(event: event).deliver(followers) if followers.any?

    # Notify venue owner if venue has an owner and artist created the event
    if artist_signed_in? && event.venue&.owner_id.present?
      venue_owner = Owner.find_by(id: event.venue.owner_id)
      EventAtVenueNotifier.with(event: event).deliver(venue_owner) if venue_owner
    end

    # Notify artist if owner created the event
    if owner_signed_in? && event.artist.present?
      artist = event.artist
      OwnerAddedEventNotifier.with(event: event).deliver(artist) if artist
    end
  end

  def apply_date_range_filter(events)
    case params[:date_range]
    when "today"
      Rails.logger.info "📅 Applying 'today' date filter"
      events.respond_to?(:today) ? events.today : events.to_a.select { |e| e.date == Date.today }
    when "next_7_days"
      Rails.logger.info "📅 Applying 'next 7 days' date filter"
      events.respond_to?(:next_7_days) ? events.next_7_days : events.to_a.select { |e| e.date.between?(Date.today, Date.today + 7) }
    else
      Rails.logger.info "📅 No date filter applied"
      events
    end
  end

  def find_nearby_events
    Rails.logger.info "🔍 Starting find_nearby_events"

    # Start with upcoming events
    events = Event.upcoming.includes(:venue, :artist)
    Rails.logger.info "📅 Found #{events.count} upcoming events total"

    # Check if we have valid location coordinates
    coordinates = search_coordinates
    if coordinates.present?
      lat, lng = coordinates

      # Validate coordinates are reasonable
      if lat.nil? || lng.nil? || lat < -90 || lat > 90 || lng < -180 || lng > 180
        Rails.logger.error "❌ Invalid coordinates: [#{lat}, #{lng}]"
        @error_message = "Invalid location coordinates. Please try a different address."
        return []
      end

      radius = search_radius
      Rails.logger.info "📍 Searching near [#{lat}, #{lng}] within #{radius} miles"

      # Use geocoder's near method without ordering to avoid distance column issue
      begin
        nearby_venues = Venue.near([lat, lng], radius, units: :mi, order: false)
        venue_ids = nearby_venues.pluck(:id)
        Rails.logger.info "🏢 Found #{venue_ids.count} venues within radius: #{venue_ids}"

        # If no venues found, return empty array
        if venue_ids.empty?
          Rails.logger.info "❌ No venues found within #{radius} miles"
          @no_results_message = "No venues found within #{radius} miles of your location. Try increasing the search radius."
          return []
        end
      rescue => e
        Rails.logger.warn "⚠️ Geocoder near method failed: #{e.message}, falling back to manual calculation"
        # Fallback: manually filter venues by distance
        all_venues = Venue.where.not(latitude: nil, longitude: nil)
        venue_ids = all_venues.select do |venue|
          distance = Geocoder::Calculations.distance_between(
            [lat, lng],
            [venue.latitude, venue.longitude],
            units: :mi,
          )
          distance <= radius
        end.map(&:id)
        Rails.logger.info "🏢 Manual calculation found #{venue_ids.count} venues within radius"

        # Same check for manual calculation
        if venue_ids.empty?
          Rails.logger.info "❌ No venues found within #{radius} miles (manual calculation)"
          @no_results_message = "No venues found within #{radius} miles of your location. Try increasing the search radius."
          return []
        end
      end

      events = events.where(venue_id: venue_ids)
      Rails.logger.info "🎭 Filtered to #{events.count} events"

      # Apply sorting based on user preference
      sort_by = params[:sort_by] || "date"
      Rails.logger.info "🔀 Sorting by: #{sort_by}"

      if sort_by == "distance"
        # Sort by distance from search location
        events = events.to_a.sort_by do |event|
          if event.venue.latitude && event.venue.longitude
            distance = Geocoder::Calculations.distance_between(
              [lat, lng],
              [event.venue.latitude, event.venue.longitude],
              units: :mi,
            )
            Rails.logger.debug "📏 Event #{event.id} distance: #{distance.round(2)} miles"
            distance
          else
            Rails.logger.warn "⚠️ Event #{event.id} has no venue coordinates"
            Float::INFINITY # Put events without coordinates at the end
          end
        end
      else
        # Sort by date/time (default)
        events = events.to_a.sort_by { |event| [event.date, event.start_time] }
        Rails.logger.info "📅 Sorted by date and time"
      end
    else
      Rails.logger.info "❌ No search coordinates provided or geocoding failed"
      @error_message = "Please provide a valid location to search for events"
      return []
    end

    events
  end

  def search_coordinates
    @search_coordinates ||= begin
        if params[:lat].present? && params[:lng].present? &&
           params[:lat] != "" && params[:lng] != ""
          # Use coordinates if they're provided (from iOS geolocation)
          lat, lng = params[:lat].to_f, params[:lng].to_f

          # Validate coordinates are reasonable
          if lat.between?(-90, 90) && lng.between?(-180, 180)
            [lat, lng]
          else
            Rails.logger.error "❌ Invalid coordinates from params: [#{lat}, #{lng}]"
            nil
          end
        elsif params[:address].present?
          # Fallback to geocoding the address
          address = params[:address].strip

          # Basic validation
          if address.length < 3
            Rails.logger.error "❌ Address too short: '#{address}'"
            nil
          else
            geocode_address(address)
          end
        else
          nil
        end
      end
  end

  def search_radius
    radius = params[:radius]&.to_f || 5.0
    # Clamp between 1 and 60 miles
    [[radius, 1.0].max, 60.0].min
  end

  def geocode_address(address)
    # Add country context to improve geocoding accuracy
    search_query = if address.match?(/^\d{5}(-\d{4})?$/)
        # If it looks like a US ZIP code, add country context
        "#{address}, USA"
      else
        address
      end

    result = Geocoder.search(search_query).first
    if result&.coordinates
      coordinates = result.coordinates
      Rails.logger.info "📍 Geocoded '#{address}' (searched: '#{search_query}') to: #{coordinates[0]}, #{coordinates[1]}"

      # Sanity check - reject coordinates that are clearly wrong for US addresses
      lat, lng = coordinates
      if address.match?(/^\d{5}(-\d{4})?$/) # US ZIP code
        # US is roughly between 24-49 latitude, -125 to -66 longitude
        if lat < 24 || lat > 49 || lng < -125 || lng > -66
          Rails.logger.warn "⚠️ Geocoded coordinates #{lat}, #{lng} seem outside US bounds for ZIP #{address}"
          return nil
        end
      end

      coordinates
    else
      Rails.logger.warn "❌ Failed to geocode address: '#{address}'"
      nil
    end
  end

  def extract_search_params
    coords = search_coordinates
    {
      address: params[:address],
      lat: coords&.first,
      lng: coords&.last,
      radius: search_radius,
      date_range: params[:date_range],
      has_location: coords.present?,
    }
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :category, :cover, :cover_amount, :date, :description,
      :start_time, :end_time, :indoors,
      :venue_id, :artist_id, :artist_name
    )
  end

  # Authorization logic
  def authorize_owner_or_admin!
    unless can_modify_event?(@event)
      redirect_to @event, alert: "You don't have permission to modify this event."
    end
  end

  def can_modify_event?(event)
    return false unless event

    # Artist who is performing can modify
    if artist_signed_in? && current_artist == event.artist
      return true
    end

    # Owner of the venue can modify
    if owner_signed_in? && current_owner.venues.include?(event.venue)
      return true
    end

    # Admin access (keeping your existing admin logic)
    if user_signed_in? && current_user.email == "pbohea@gmail.com"
      return true
    end

    false
  end

  # notifications
  # def notify_followers(event)
  #   artist = event.artist
  #   return unless artist

  #   artist.followers.each do |user|
  #     NewEventNotifier.with(event: event).deliver(user)
  #   end
  # end

  # def notify_artist(event)
  #   artist = event.artist
  #   return unless artist

  #   NewEventNotifier.with(event: event).deliver(artist)
  # end
end
