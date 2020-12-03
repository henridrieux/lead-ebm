require 'rest-client'
require 'json'

class NotifySlack < ApplicationJob
  include RestClient

  def perform(event_category, url)
    puts "executing...."
    hash = event_category.slack_json_leads
    hash.each do |lead|
      RestClient.post(url,
                  lead.to_json,
                  headers = { content_type: "application/json", accept: :json })
    end
  end

  def welcome(event_category, url)
    message = event_category.slack_welcome
    RestClient.post(url,
                message.to_json,
                headers = { content_type: "application/json", accept: :json })
  end
end
