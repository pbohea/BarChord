# == Schema Information
#
# Table name: notification_tokens
#
#  id         :bigint           not null, primary key
#  platform   :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notification_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class NotificationToken < ApplicationRecord
  belongs_to :notifiable, polymorphic:true

  validates :token, presence: true
  validates :platform, inclusion: {in: %w[iOS]}
end
