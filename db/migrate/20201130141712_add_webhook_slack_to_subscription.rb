class AddWebhookSlackToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :webhook_slack, :text, default: "https://hooks.slack.com/services/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"
  end
end
