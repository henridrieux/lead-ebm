class QueueJob < ApplicationJob
  queue_as :default

  def perform
    puts "I'm starting the queue job"
    sleep 3
    puts "OK I'm done now"
  end
end
