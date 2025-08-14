module EventsHelper
  def date_options(venue = nil)
    # Determine the timezone based on venue location
    timezone = venue_timezone(venue)
    venue_tz = ActiveSupport::TimeZone.new(timezone)
    
    # Generate dates starting from today in the venue's timezone
    venue_today = venue_tz.now.to_date
    
    dates = []
    (0..30).each do |i|
      date = venue_today + i.days
      dates << [date.strftime("%A, %B %-d"), date.to_s]
    end
    
    dates
  end

  def time_options(venue = nil, selected_date = nil)
    # Determine the timezone based on venue location
    timezone = venue_timezone(venue)
    venue_tz = ActiveSupport::TimeZone.new(timezone)
    
    # Parse the selected date or use today IN THE VENUE'S TIMEZONE
    event_date = selected_date.present? ? Date.parse(selected_date.to_s) : venue_tz.now.to_date
    is_today = event_date == venue_tz.now.to_date  # Compare in venue's timezone
    
    Rails.logger.info "🕐 Venue timezone: #{timezone}, Venue date: #{venue_tz.now.to_date}, Event date: #{event_date}, Is today?: #{is_today}"
    
    times = []
    
    # Determine start time based on date
    if is_today
      # For today, start from the next 15-minute interval in venue timezone
      current_time_in_venue_tz = venue_tz.now
      # Round up to next 15-minute interval
      minutes = current_time_in_venue_tz.min
      rounded_minutes = ((minutes / 15.0).ceil * 15) % 60
      hours_to_add = (minutes + 14) / 60  # Add an hour if rounding pushes us over
      start_time = current_time_in_venue_tz.beginning_of_hour + 
                   hours_to_add.hours + 
                   rounded_minutes.minutes
    else
      # For future dates, start at 9:00 AM in venue timezone
      start_time = Time.zone.parse("9:00 AM").in_time_zone(timezone)
      start_time = start_time.change(
        year: event_date.year,
        month: event_date.month,
        day: event_date.day
      )
    end
    
    # End at 11:45 PM same day for start times
    end_time = start_time.beginning_of_day + 23.hours + 45.minutes
    
    current_time = start_time
    while current_time <= end_time
      # Format for display (in venue timezone)
      display_time = current_time.strftime("%-I:%M %p")
      # Value for form (24-hour format, but we'll store as is)
      value_time = current_time.strftime("%H:%M")
      
      times << [display_time, value_time]
      current_time += 15.minutes
    end
    
    times
  end
  
  def end_time_options(venue = nil, selected_date = nil, start_time = nil)
    # Similar to time_options but ensures end time is after start time
    timezone = venue_timezone(venue)
    event_date = selected_date.present? ? Date.parse(selected_date.to_s) : Date.current
    
    times = []
    
    if start_time.present?
      # Parse start time and add 15 minutes as minimum duration
      start_hour, start_minute = start_time.split(':').map(&:to_i)
      
      # Create the start time directly in the venue's timezone (Method 2 from console test)
      venue_tz = ActiveSupport::TimeZone.new(timezone)
      min_end_time = venue_tz.parse("#{event_date} #{start_hour}:#{start_minute}") + 15.minutes
      
      Rails.logger.info "🕐 Start time: #{start_time}, Venue TZ: #{timezone}, Min end time: #{min_end_time}"
    else
      # Default minimum end time
      min_end_time = Time.zone.parse("9:15 AM").in_time_zone(timezone)
      min_end_time = min_end_time.change(
        year: event_date.year,
        month: event_date.month,
        day: event_date.day
      )
    end
    
    # End options go until 4 AM next day
    max_end_time = min_end_time.beginning_of_day + 1.day + 4.hours
    
    Rails.logger.info "🕐 Event date: #{event_date}, Min end time: #{min_end_time}, Max end time: #{max_end_time}"
    
    current_time = min_end_time
    while current_time <= max_end_time
      # Only label times as "next day" if they're in the early morning hours (12 AM - 4 AM)
      if current_time.hour >= 0 && current_time.hour < 4 && current_time.day > min_end_time.day
        display_time = "#{current_time.strftime('%-I:%M %p')}"
      else
        display_time = current_time.strftime("%-I:%M %p")
      end
      
      value_time = current_time.strftime("%H:%M")
      
      times << [display_time, value_time]
      current_time += 15.minutes
    end
    
    times
  end
  
  private
  
  def venue_timezone(venue)
    return 'UTC' unless venue&.state
    
    # US timezone mapping with coordinate precision for multi-timezone states
    case venue.state.upcase
    # States with multiple timezones - use coordinates for precision
    when 'TX'
      # Most of Texas is Central, but far west (El Paso area) is Mountain
      venue.longitude && venue.longitude < -106 ? 'America/Denver' : 'America/Chicago'
    when 'FL'
      # Most of Florida is Eastern, but western panhandle is Central
      venue.longitude && venue.longitude < -87.5 ? 'America/Chicago' : 'America/New_York'
    when 'IN'
      # Most of Indiana is Eastern, but northwest and southwest corners are Central
      venue.longitude && venue.longitude < -87.0 ? 'America/Chicago' : 'America/New_York'
    when 'MI'
      # Most of Michigan is Eastern, but western Upper Peninsula is Central
      if venue.latitude && venue.longitude
        # Western UP counties (rough boundary)
        venue.latitude > 45.5 && venue.longitude < -87.5 ? 'America/Chicago' : 'America/New_York'
      else
        'America/New_York' # Default to Eastern for Michigan
      end
    when 'KY'
      # Most of Kentucky is Eastern, but western part is Central
      venue.longitude && venue.longitude < -86.0 ? 'America/Chicago' : 'America/New_York'
    when 'TN'
      # Most of Tennessee is Central, but eastern part is Eastern
      venue.longitude && venue.longitude > -85.0 ? 'America/New_York' : 'America/Chicago'
    when 'ND', 'SD'
      # Western parts are Mountain, eastern parts are Central
      venue.longitude && venue.longitude < -103.5 ? 'America/Denver' : 'America/Chicago'
    when 'NE'
      # Western Nebraska is Mountain, eastern is Central
      venue.longitude && venue.longitude < -104.0 ? 'America/Denver' : 'America/Chicago'
    when 'KS'
      # Western Kansas counties are Mountain, eastern is Central
      venue.longitude && venue.longitude < -101.5 ? 'America/Denver' : 'America/Chicago'
    when 'OR'
      # Most of Oregon is Pacific, but eastern Oregon (Malheur County) is Mountain
      venue.longitude && venue.longitude > -117.0 ? 'America/Denver' : 'America/Los_Angeles'
    when 'ID'
      # Northern Idaho is Pacific, southern Idaho is Mountain
      venue.latitude && venue.latitude > 45.0 ? 'America/Los_Angeles' : 'America/Denver'
    
    # Single timezone states
    # Pacific Time
    when 'CA', 'WA', 'NV'
      'America/Los_Angeles'
    # Mountain Time  
    when 'MT', 'WY', 'CO', 'NM', 'UT'
      'America/Denver'
    # Central Time
    when 'MN', 'IA', 'MO', 'AR', 'LA', 'WI', 'IL', 'MS', 'AL', 'OK'
      'America/Chicago'
    # Eastern Time
    when 'ME', 'NH', 'VT', 'MA', 'RI', 'CT', 'NY', 'NJ', 'PA', 'DE', 'MD', 'DC', 'VA', 'WV', 'OH', 'NC', 'SC', 'GA'
      'America/New_York'
    # Special cases
    when 'AK'
      # Alaska has multiple zones, but most businesses are in Alaska Time
      'America/Anchorage'
    when 'HI'
      'Pacific/Honolulu'
    when 'AZ'
      # Most of Arizona doesn't observe DST (except Navajo Nation)
      'America/Phoenix'
    else
      # Fallback to longitude-based for unknown states/territories
      return 'UTC' unless venue&.latitude && venue&.longitude
      
      case venue.longitude
      when -180..-125
        'America/Anchorage'  # Alaska/Aleutian
      when -125..-120
        'America/Los_Angeles'  # Pacific
      when -120..-104
        'America/Denver'  # Mountain
      when -104..-87
        'America/Chicago'  # Central
      when -87..-67
        'America/New_York'  # Eastern
      else
        'UTC'
      end
    end
  end
end
