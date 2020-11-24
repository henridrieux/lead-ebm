class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :events_category
  validates :status, presence: true
  validates :start_date, presence: true
end
