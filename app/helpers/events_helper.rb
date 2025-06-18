module EventsHelper
  def time_options
    times = []
    # Start at 12:00 AM (midnight)
    time = Time.zone.parse("12:00 AM")
    # Go for a full 24 hours (96 intervals of 15 minutes each)
    96.times do
      times << [time.strftime("%-I:%M %p"), time.strftime("%H:%M")]
      time += 15.minutes
    end
    times
  end
end
