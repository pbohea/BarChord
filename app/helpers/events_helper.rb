module EventsHelper
    def time_options
    times = []
    time = Time.zone.parse("12:00 PM")
    while time < Time.zone.parse("11:59 PM")
      times << [time.strftime("%-I:%M %p"), time.strftime("%H:%M")]
      time += 15.minutes
    end
    times
  end
end
