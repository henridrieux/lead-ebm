class AddSlackWebhookToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :slack_webhook, :text, default: "https://hooks.slack.com/services/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"
  end
end
