class MakeNotificationTokenPolymorphic < ActiveRecord::Migration[7.1]
  def change
    remove_reference :notification_tokens, :user, index: true, foreign_key: true
    add_reference :notification_tokens, :notifiable, polymorphic: true, index: true
  end
end
