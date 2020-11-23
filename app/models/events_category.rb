class EventsCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
end
