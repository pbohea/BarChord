module EventsHelper
  def time_options
    times = []
    # Start at 6:00 AM instead of 12:00 PM
    time = Time.zone.parse("6:00 AM")
    # Go until 11:59 PM
    while time < Time.zone.parse("11:59 PM")
      times << [time.strftime("%-I:%M %p"), time.strftime("%H:%M")]
      time += 15.minutes
    end
    times
  end
end
