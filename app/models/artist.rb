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
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tiktok_url             :string
#  type                   :string
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
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, foreign_key: "artist_id"
  has_many :venues, through: :events  
  has_many :artist_follows
  has_many :followers, through: :artist_follows, source: :user

  has_one_attached :image

end
