class Recruitment < ApplicationRecord
  belongs_to :category
  belongs_to :company
  validates :employer, presence: true
  validates :job_title, presence: true
  # validates :contract_type, presence: true
  # validates :publication_date, presence: true
  validates :external_id, presence: true, uniqueness: true

  # def slack
  # POST https://hooks.slack.com/services/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
  # Content-type: application/json
  # {
  #    "text": "Hello, world."
  # }
  # end
end
