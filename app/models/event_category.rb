class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  has_many :companies, through: :category
  has_many :recruitments, through: :categories
  has_many :subscriptions
  validates :title, presence: true

  validates :category, uniqueness: { scope: :event, message: "can't be associated twice to the same event" }

  def get_company_leads
    companies = Company.includes(:event_categories, :category).where(category: self.category)
    query = self.event.query
    # query = "creation_date > :limit_date"
    query = ""
    query_params = " \
    limit_date: #{Date.today - 300} \
    "
    @leads =  companies ? companies.where(query, query_params) : nil
    return @leads
  end


end

