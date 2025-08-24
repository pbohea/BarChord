# == Schema Information
#
# Table name: artists
#
#  id                     :bigint           not null, primary key
#  bio                    :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  firstname              :string
#  genre                  :string
#  image                  :string
#  instagram_url          :string
#  lastname               :string
#  performance_type       :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  spotify_url            :string
#  tiktok_url             :string
#  username               :string
#  website                :string
#  youtube_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_artists_on_email                 (email) UNIQUE
#  index_artists_on_reset_password_token  (reset_password_token) UNIQUE
#
class Artist < ApplicationRecord
  require "net/http"
  require "uri"

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :events, foreign_key: "artist_id"
  has_many :venues, through: :events
  has_many :artist_follows, dependent: :destroy
  has_one_attached :image
  has_many :notification_tokens
  has_many :artist_follows, as: :follower, dependent: :destroy
  has_many :followed_artists, through: :artist_follows, source: :artist
  has_many :venue_follows, as: :follower, dependent: :destroy
  has_many :followed_venues, through: :venue_follows, source: :venue

  # Constants
  GENRES = ["Country", "Rock", "Alternative", "Jazz", "Electronic", "Hip-Hop", "Pop", "Folk", "Other"].freeze
  PERFORMANCE_TYPES = ["Guitar", "Piano", "Band", "DJ", "Other"].freeze

  # Validations
  validate :password_complexity
  validates :bio, length: { maximum: 140, message: "must be 140 characters or less" }
  validate :website_https_supported, if: -> { website.present? }

  # Normalize socials before validation
  before_validation :normalize_social_urls
  before_validation :generate_slug

  # Instance Methods
  def upcoming_events
    events.upcoming
  end

  def past_events
    events.past
  end

  def followers
    ArtistFollow.where(artist: self).includes(:follower).map(&:follower)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if username.blank?
    
    base_slug = username.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/-+/, '-').strip('-')
    base_slug = 'artist' if base_slug.blank?
    
    slug_candidate = base_slug
    counter = 1
    
    while Artist.where(slug: slug_candidate).where.not(id: id).exists?
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = slug_candidate
  end

  def password_complexity
    return if password.blank?

    unless password.length.between?(8, 20)
      errors.add :password, "must be between 8 and 20 characters"
    end

    unless password.match?(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one number"
    end
  end

  def website_https_supported
    uri = normalize_url(website)

    if uri
      if https_works?(uri)
        self.website = uri.to_s
      else
        errors.add(:website, "must support HTTPS (https://...)")
      end
    else
      errors.add(:website, "is not a valid URL")
    end
  end

  def normalize_url(url)
    uri = URI.parse(url)
    uri = URI.parse("https://#{url}") unless uri.scheme
    uri
  rescue URI::InvalidURIError
    nil
  end

  def https_works?(uri)
    uri.scheme = "https"
    uri.port = 443

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 2) do |http|
      http.head(uri.path.empty? ? "/" : uri.path)
    end

    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  rescue StandardError => e
    Rails.logger.warn("HTTPS check failed for #{uri}: #{e.message}")
    false
  end

  def normalize_social_urls
    %i[instagram_url youtube_url tiktok_url spotify_url].each do |attr|
      raw = self[attr]
      next if raw.blank?

      uri = normalize_url(raw)
      self[attr] = uri.to_s.chomp("/") if uri
    end
  end
end
