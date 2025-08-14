# app/mailers/venue_approval_mailer.rb
class VenueApprovalMailer < ApplicationMailer
  def venue_approved(venue_request)
    @venue_request = venue_request
    @venue = if venue_request.venue_id.present?
               Venue.find_by(id: venue_request.venue_id)
             else
               venue_request.existing_venue
             end
    @owner = Owner.find_by(id: venue_request.requester_id)
    
    return unless @owner&.email.present? && @venue.present?
    
    # Generate venue page URL
    @venue_url = venue_url(@venue)
    
    mail(
      to: @owner.email,
      subject: "Your BarChord venue claim has been approved!"
    )
  end
end
