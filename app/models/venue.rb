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

  has_one_attached :image

  geocoded_by :full_address, latitude: :latitude, longitude: :longitude


  before_validation :normalize_website_url

  validates :name, :street_address, :city, :state, :zip_code, presence: true
  validates :website, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  before_save :geocode_address, if: :address_changed?

  CATEGORIES = ["Bar", "Jazz Club", "Nightclub", "Pub", "Cafe"].freeze

  def full_address
    [street_address, city, state, zip_code].compact.join(", ")
  end

  private

  def normalize_website_url
    return if website.blank?

    unless website =~ /\Ahttps?:\/\//
      self.website = "https://#{website.strip}"
    end
  end

  def address_changed?
    street_address_changed? || city_changed? || state_changed? || zip_code_changed?
  end

  def geocode_address
    result = Geocoder.search(full_address).first
    if result&.coordinates
      self.latitude = result.latitude
      self.longitude = result.longitude
    end
  end
end
