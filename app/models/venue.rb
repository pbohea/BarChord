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
#  place_id       :string
#
# Indexes
#
#  index_venues_on_place_id  (place_id)
#
class Venue < ApplicationRecord
  belongs_to :owner, optional: true
  has_many :events
  has_many :venue_follows, dependent: :destroy

  has_one_attached :image

  geocoded_by :full_address, latitude: :latitude, longitude: :longitude

  before_validation :normalize_website_url
  before_validation :generate_slug

  validates :name, :street_address, :city, :state, :zip_code, presence: true
  validates :website, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
  validates :place_id, uniqueness: true, allow_nil: true

  before_save :geocode_address, if: :address_changed?

  CATEGORIES = [
    "Bar",
    "Bar & Restaurant",
    "Cafe",
    "Jazz Club",
    "Nightclub",
    "Pub",
    "Restaurant",
  ].freeze

  def full_address
    [street_address, city, state, zip_code].compact.join(", ")
  end

  def followers
    VenueFollow.where(venue: self).includes(:follower).map(&:follower)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if name.blank?
    
    base_slug = name.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/-+/, '-').strip('-')
    base_slug = 'venue' if base_slug.blank?
    
    slug_candidate = base_slug
    counter = 1
    
    while Venue.where(slug: slug_candidate).where.not(id: id).exists?
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = slug_candidate
  end

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
