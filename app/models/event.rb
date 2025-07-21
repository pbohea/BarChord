# == Schema Information
#
# Table name: events
#
#  id           :bigint           not null, primary key
#  artist_name  :string
#  category     :string
#  cover        :boolean
#  cover_amount :integer
#  date         :date
#  description  :string
#  end_time     :datetime
#  indoors      :boolean
#  start_time   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  artist_id    :integer
#  venue_id     :integer
#
class Event < ApplicationRecord
  belongs_to :venue
  belongs_to :artist, optional: true

  before_save :adjust_end_time_for_overnight_events
  before_save :set_artist_name_from_artist
  before_save :set_category_from_artist

  scope :upcoming, -> { where("date >= ?", Date.today).order(:date, :start_time) }
  scope :past, -> { where("date < ?", Date.today).order(date: :desc, start_time: :desc) }
  scope :today, -> { where(date: Date.today) }
  scope :next_7_days, -> { where(date: Date.today..(Date.today + 7)) }

  validate :artist_presence

  private

  def adjust_end_time_for_overnight_events
    return unless date.present? && start_time.present? && end_time.present?

    # Parse the time strings if they come from the form
    start_hour, start_min = parse_time_string(start_time)
    end_hour, end_min = parse_time_string(end_time)

    # Create full datetime objects
    start_datetime = date.beginning_of_day + start_hour.hours + start_min.minutes
    end_datetime = date.beginning_of_day + end_hour.hours + end_min.minutes

    # If end time is earlier than start time, assume it's the next day
    if end_datetime <= start_datetime
      end_datetime += 1.day
    end

    self.start_time = start_datetime
    self.end_time = end_datetime
  end

  def parse_time_string(time_input)
    if time_input.is_a?(String)
      # Handle "HH:MM" format from form
      hour, min = time_input.split(":").map(&:to_i)
    else
      # Handle datetime object
      hour = time_input.hour
      min = time_input.min
    end
    [hour, min]
  end

  def set_artist_name_from_artist
    if artist_id.present? && artist.present?
      self.artist_name = artist.username
    end
  end

  def set_category_from_artist
    if artist_id.present? && artist.present? && artist.performance_type.present?
      self.category = artist.performance_type
    end
  end


  def artist_presence
    if artist_id.blank? && artist_name.blank?
      errors.add(:base, "Please select an artist or enter a name.")
    end
  end
end
