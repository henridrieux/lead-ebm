class Company < ApplicationRecord
  belongs_to :category
  has_many :event_categories, through: :category

  validates :company_name, presence: true
  validates :siret, presence: true
  validates :siren, presence: true
  validates :naf_code, presence: true
  #validates :rcs_inscription, presence: true
  #validates :manager_birth_year, presence: true
end
