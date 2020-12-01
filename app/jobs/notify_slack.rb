require 'rest-client'
require 'json'

class NotifySlack < ApplicationJob
  include RestClient

  def post_to_slack(event_category)
    puts "executing...."
    hash = event_category.slack_json_leads
    p hash
    p hash[:category_name]
    p hash[:event_title]
    # hash[:leads].each do |lead|
    #   p lead
    # end
    RestClient.post("https://hooks.slack.com/services/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",
                {"text" => "hello"}.to_json,
                headers = { content_type: "application/json", accept: :json })
  end

end
