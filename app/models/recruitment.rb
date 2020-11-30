class Recruitment < ApplicationRecord
  belongs_to :category
  belongs_to :company
  validates :employer, presence: true
  validates :job_title, presence: true
  # validates :contract_type, presence: true
  # validates :publication_date, presence: true
  validates :external_id, presence: true, uniqueness: true
end
