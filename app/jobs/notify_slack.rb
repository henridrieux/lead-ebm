require 'rest-client'
require 'json'

class NotifySlack < ApplicationJob
  include RestClient

  def perform(event_category)
    puts "executing...."
    hash = event_category.slack_json_leads
    hash.each do |lead|
      p lead
      RestClient.post(ENV["SLACK_LEAD_INCOMING_WEBHOOK_URL"],
                  lead.to_json,
                  headers = { content_type: "application/json", accept: :json })
    end

  end
end
