class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :events_category
end
