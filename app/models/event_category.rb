class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  has_many :recruitments, through: :categories
  validates :title, presence: true
end

