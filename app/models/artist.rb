# == Schema Information
#
# Table name: artists
#
#  id                     :bigint           not null, primary key
#  bio                    :text
#  category               :string
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
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validate :password_complexity
  validates :bio, length: { maximum: 140, message: "must be 140 characters or less" }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, foreign_key: "artist_id"
  has_many :venues, through: :events
  has_many :artist_follows
  has_many :followers, through: :artist_follows, source: :user
  has_many :notification_tokens, as: :notifiable, dependent: :destroy

  has_one_attached :image

  GENRES = ["Country", "Rock", "Alternative", "Jazz", "Electronic", "Hip-Hop", "Pop", "Folk", "Other"].freeze
  PERFORMANCE_TYPES = ["Solo Guitar", "Solo Piano", "Band", "DJ", "Other"].freeze

  def upcoming_events
    events.upcoming
  end

  def past_events
    events.past
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
end
