class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authorize_owner_or_admin!, only: %i[edit update destroy]

  # GET /events
  def index
    Rails.logger.info "🔍 EVENTS INDEX HIT - User-Agent: #{request.user_agent}"
    Rails.logger.info "🔍 REQUEST FORMAT: #{request.format}"
    Rails.logger.info "🔍 REQUEST PARAMS: #{params.inspect}"

    if params[:address].present? || params[:lat].present?
      # User is searching by location - filter results
      @events = find_nearby_events
      @search_params = extract_search_params
    else
      # Default - show all upcoming events
      @events = Event.upcoming.includes(:venue, :artist)
      @search_params = nil
    end

    respond_to do |format|
      format.html
      format.json { render json: @events } # Add JSON support for iOS
      format.turbo_stream { render :index }
    end
  end

  # GET /events/nearby - New filtered endpoint
  def nearby
    Rails.logger.info "🔍 NEARBY ENDPOINT HIT with params: #{params.inspect}"

    @events = find_nearby_events
    @search_params = extract_search_params

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
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        notify_followers(@event)
        notify_artist(@event)

        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  def update
    respond_to do |format|
      if @event.update(event_params)
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
          redirect_to artist_dashboard_path, status: :see_other, notice: "Event has been cancelled successfully."
        elsif owner_signed_in?
          redirect_to owner_dashboard_path, status: :see_other, notice: "Event has been cancelled successfully."
        else
          redirect_to events_path, status: :see_other, notice: "Event has been cancelled successfully."
        end
      }
    end
  end

  def map
    @events = Event.upcoming.includes(:venue, :artist)

    # Add venue-specific centering params for jbuilder template
    @center_lat = params[:lat]&.to_f
    @center_lng = params[:lng]&.to_f
    @selected_venue_id = params[:venue_id]&.to_i

    respond_to do |format|
      format.json # This will use map.json.jbuilder
      format.html
    end
  end

  private

  def find_nearby_events
    Rails.logger.info "🔍 Starting find_nearby_events"

    # Start with upcoming events
    events = Event.upcoming.includes(:venue, :artist)
    Rails.logger.info "📅 Found #{events.count} upcoming events total"

    # If we have location coordinates, filter by distance
    if search_coordinates.present?
      lat, lng = search_coordinates
      radius = search_radius

      Rails.logger.info "📍 Searching near [#{lat}, #{lng}] within #{radius} miles"

      # Use geocoder's near method without ordering to avoid distance column issue
      begin
        nearby_venues = Venue.near([lat, lng], radius, units: :mi, order: false)
        venue_ids = nearby_venues.pluck(:id)
        Rails.logger.info "🏢 Found #{venue_ids.count} venues within radius: #{venue_ids}"
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
      end

      events = events.where(venue_id: venue_ids)
      Rails.logger.info "🎭 Filtered to #{events.count} events"

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
      Rails.logger.info "❌ No search coordinates provided"
    end

    events
  end

  def search_coordinates
    @search_coordinates ||= begin
        if params[:lat].present? && params[:lng].present? &&
           params[:lat] != "" && params[:lng] != ""
          # Use coordinates if they're provided (from iOS geolocation)
          [params[:lat].to_f, params[:lng].to_f]
        elsif params[:address].present?
          # Fallback to geocoding the address
          geocode_address(params[:address])
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
      has_location: coords.present?,
    }
  end

  # Remove the radius_to_degrees helper since we're using geocoder's near method

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :category, :cover, :date, :description,
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
  def notify_followers(event)
    artist = event.artist
    return unless artist

    artist.followers.each do |user|
      NewEventNotifier.with(event: event).deliver(user)
    end
  end

  def notify_artist(event)
    artist = event.artist
    return unless artist

    NewEventNotifier.with(event: event).deliver(artist)
  end
end
