class Company < ApplicationRecord
  belongs_to :category
  validates :company_name, presence: true
  validates :SIRET, presence: true
  validates :SIREN, presence: true
  validates :naf_code, presence: true
  #validates :rcs_inscription, presence: true
  #validates :manager_birth_year, presence: true
end
