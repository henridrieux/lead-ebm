class Category < ApplicationRecord
  has_many :companies
  has_many :event_categories
  has_many :subscriptions, through: :event_categories
  has_one_attached :photo

  validates :name, presence: true
  validates :description, presence: true
end

