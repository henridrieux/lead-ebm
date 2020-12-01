class AddSlackWebhookToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :slack_webhook, :text
  end
end
