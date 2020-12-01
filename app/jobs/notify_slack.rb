require 'rest-client'
require 'json'

class NotifySlack < ApplicationJob
  include RestClient

  def post_to_slack(event_category)
    puts "executing...."
    hash = event_category.slack_json_leads
    hash.each do |lead|
      p lead
      RestClient.post("https://hooks.slack.com/services/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",
                  lead.to_json,
                  headers = { content_type: "application/json", accept: :json })
    end

  end
end
