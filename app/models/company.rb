class Company < ApplicationRecord
  belongs_to :category
  has_many :event_categories, through: :category
  has_many :events, through: :event_categories
  has_many :recruitments

  validates :company_name, presence: true
  validates :siret, presence: true
  validates :siren, presence: true
  validates :naf_code, presence: true
end
