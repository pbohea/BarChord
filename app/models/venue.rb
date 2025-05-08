# == Schema Information
#
# Table name: venues
#
#  id           :bigint           not null, primary key
#  address      :string
#  category     :string
#  events_count :integer
#  name         :string
#  website      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer
#
class Venue < ApplicationRecord
  belongs_to :owner
  has_many :events
  has_many :venue_follows
  has_many :followers, through: :venue_follows, source: :user

end
