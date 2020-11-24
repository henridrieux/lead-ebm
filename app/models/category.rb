class Category < ApplicationRecord
  has_many :event_categories
  validates :name, presence: true
  validates :description, presence: true
end
