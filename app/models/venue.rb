# == Schema Information
#
# Table name: venues
#
#  id             :bigint           not null, primary key
#  category       :string
#  city           :string
#  events_count   :integer
#  latitude       :float
#  longitude      :float
#  name           :string
#  state          :string
#  street_address :string
#  website        :string
#  zip_code       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_id       :integer
#
class Venue < ApplicationRecord
  belongs_to :owner
  has_many :events
  has_many :venue_follows
  has_many :followers, through: :venue_follows, source: :user

  before_save :geocode_address, if: :address_changed?

  def full_address
    [street_address, city, state, zip_code].compact.join(', ')
  end

  private

  def address_changed?
    street_address_changed? || city_changed? || state_changed? || zip_code_changed?
  end

  def geocode_address
    results = Geocoder.search(full_address)
    if coords = results.first&.coordinates
      self.latitude = coords[0]
      self.longitude = coords[1]
    end
  end
end
