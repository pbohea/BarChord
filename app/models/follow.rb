# == Schema Information
#
# Table name: follows
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  artist_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_follows_on_artist_id  (artist_id)
#  index_follows_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (user_id => users.id)
#
class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  validates :user_id, uniqueness: { scope: :artist_id }
end
