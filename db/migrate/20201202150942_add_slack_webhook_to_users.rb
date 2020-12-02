class AddSlackWebhookToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :webhook_slack, :text
    remove_column :subscriptions, :slack_webhook, :text
  end
end
