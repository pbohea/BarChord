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

  scope :upcoming, -> { where("date >= ?", Date.today).order(:date, :start_time) }

  validate :artist_presence

  def artist_presence
    if artist_id.blank? && artist_name.blank?
      errors.add(:base, "Please select an artist or enter a name.")
    end
  end
end
