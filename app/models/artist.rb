# == Schema Information
#
# Table name: artists
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  firstname              :string
#  genre                  :string
#  lastname               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string
#  website                :string
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
  has_many :events, foreign_key: "event_id"
  has_many :played_at, class_name: "Venue", foreign_key: "venue_id"

end
