class Category < ApplicationRecord
  has_many :event_categories
  validates :name, presence: true
  validates :description, presence: true
  has_one_attached :photo
end
