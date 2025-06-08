# == Schema Information
#
# Table name: notification_tokens
#
#  id              :bigint           not null, primary key
#  notifiable_type :string
#  platform        :string           not null
#  token           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :bigint
#
# Indexes
#
#  index_notification_tokens_on_notifiable  (notifiable_type,notifiable_id)
#
class NotificationToken < ApplicationRecord
  belongs_to :notifiable, polymorphic:true

  validates :token, presence: true
  validates :platform, inclusion: {in: %w[iOS]}
end
