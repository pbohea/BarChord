# == Schema Information
#
# Table name: venues
#
#  id             :bigint           not null, primary key
#  address        :string
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

  def full_address
  [street_address, city, state, zip_code].compact.join(', ')
  end
  
end
