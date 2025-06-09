class VenuesController < ApplicationController
  before_action :set_venue, only: %i[ show edit update destroy ]
  before_action :authenticate_owner!, only: [:claim]
  # GET /venues or /venues.json
  def index
    @venues = Venue.all
  end

  # GET /venues/1 or /venues/1.json
  def show
    @upcoming_events = @venue.events.upcoming
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "venues/show", locals: { venue: @venue }
        else
          render :show
        end
      end
    end
  end

  # GET /venues/new
  def new
    @venue = Venue.new
  end

  def search
    query = params[:query].to_s.strip.downcase
    venues = Venue.where("LOWER(name) LIKE ?", "%#{query}%")
                  .select(:id, :name)
                  .limit(5)

    render json: venues
  end

  # GET /venues/1/edit
  def edit
  end

  # POST /venues or /venues.json
  def create
    @venue = current_owner.venues.build(venue_params)

    respond_to do |format|
      if @venue.save
        format.html { redirect_to @venue, notice: "Venue was successfully created." }
        format.json { render :show, status: :created, location: @venue }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /venues/1 or /venues/1.json
  def update
    respond_to do |format|
      if @venue.update(venue_params)
        format.html { redirect_to @venue, notice: "Venue was successfully updated." }
        format.json { render :show, status: :ok, location: @venue }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @venue.destroy!

    respond_to do |format|
      format.html { redirect_to venues_path, status: :see_other, notice: "Venue was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def upcoming_events
    @venue = Venue.find(params[:id])
    @events = @venue.events.upcoming

    render partial: "venues/upcoming_events", locals: { venue: @venue, events: @events }, layout: false
  end

  def claim
    #renders the form
  end

  def claim_submit
    @venue = Venue.find(params[:venue_id])

    if current_owner && @venue.owner_id.nil?
      @venue.update(owner_id: current_owner.id)
      redirect_to owner_dashboard_path(current_owner), notice: "Venue successfully claimed!"
    else
      redirect_to claim_venue_path, alert: "That venue is already claimed or you're not signed in as an owner."
    end
  end

  private

  def set_venue
    @venue = Venue.find(params.expect(:id))
  end

  def venue_params
    params.require(:venue).permit(
      :name,
      :category,
      :website,
      :street_address,
      :city,
      :state,
      :zip_code,
      :latitude,
      :longitude,
      :image
    )
  end
end
