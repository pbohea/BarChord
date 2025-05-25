class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authorize_owner_or_admin!, only: %i[edit update destroy]

  # GET /events
  def index
    @events = Event.all
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
      format.html { redirect_to events_path, status: :see_other, notice: "Event was successfully destroyed." }
      #format.json { head :no_content }
    end
  end

  def map
    @events = Event.upcoming.includes(:venue, :artist)

    respond_to do |format|
      format.json
      format.html
    end
  end

  private

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
    venue_owner_id = @event.venue&.owner_id

    authorized = owner_signed_in? && current_owner.id == venue_owner_id

    authorized ||= user_signed_in? && current_user.email == "pbohea@gmail.com"

    unless authorized
      redirect_to events_path, alert: "You are not authorized to modify this event."
    end
  end

  # notificaitons
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
