class AdminController < ApplicationController
  before_action :authorize_admin!

  def dashboard
    @pending_venue_requests = VenueRequest.pending.order(created_at: :desc)
    @recent_approved = VenueRequest.approved.order(updated_at: :desc).limit(5)
    @recent_rejected = VenueRequest.rejected.order(updated_at: :desc).limit(5)
    
    @stats = {
      total_requests: VenueRequest.count,
      pending_count: VenueRequest.pending.count,
      approved_count: VenueRequest.approved.count,
      rejected_count: VenueRequest.rejected.count,
      ownership_claims: VenueRequest.where(ownership_claim: true).count,
      new_venue_requests: VenueRequest.where(request_type: 'new_venue').count
    }
  end

  def venue_requests
    @venue_requests = VenueRequest.order(created_at: :desc)
    
    # Filter by status if provided
    if params[:status].present? && VenueRequest.statuses.key?(params[:status])
      @venue_requests = @venue_requests.where(status: params[:status])
    end

    # Filter by type if provided
    if params[:type].present? && %w[new_venue existing_venue_claim].include?(params[:type])
      @venue_requests = @venue_requests.where(request_type: params[:type])
    end
  end

  private

  def authorize_admin!
    unless is_admin?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def is_admin?
    user_signed_in? && current_user.email == "pbohea@gmail.com"
  end
end
