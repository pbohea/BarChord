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

  def status_color(status)
    case status.to_s
    when "pending"
      "warning"
    when "approved"
      "success"
    when "rejected"
      "danger"
    when "duplicate"
      "secondary"
    else
      "secondary"
    end
  end

  def is_admin_email?(email)
    email == "pbohea@gmail.com"
  end
end
