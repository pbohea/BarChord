module ApplicationHelper
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

    # Admin access
    if user_signed_in? && current_user.email == "pbohea@gmail.com"
      return true
    end

    false
  end
end
