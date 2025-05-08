# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  category    :string
#  cover       :boolean
#  date        :date
#  description :string
#  end_time    :datetime
#  indoors     :boolean
#  start_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  artist_id   :integer
#  venue_id    :integer
#
class Event < ApplicationRecord
  belongs_to :venue
end
