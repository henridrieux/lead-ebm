class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  has_many :companies, through: :category
  has_many :recruitments, through: :categories
  has_many :subscriptions
  validates :title, presence: true

  validates :category, uniqueness: { scope: :event, message: "can't be associated twice to the same event" }

  def get_company_leads
    if self.event.title == "Les sociétés qui recrutent"
      companies = Company.joins(:recruitments)
      query = self.event.query
      query = "recruitments.id > 0"
      query_params = self.event.query_params
      rec_companies = companies ? companies.where(query, query_params) : nil
      @leads = rec_companies
    else
      companies = Company.includes(:category, :events, :recruitments).where(category: self.category)
      query = self.event.query
      query_params = " \
      #{Date.today - self.event.query_params.to_i } \
      "
      @leads = companies ? companies.where(query, query_params) : nil
    end
    return @leads
  end

  def json_leads
    leads = self.get_company_leads
    json_leads = {
      category_name: self.category.name,
      event_title: self.event.title,
      sending_date: Date.today,
      leads: [],
    }
    leads.each do |lead|
      json_lead = {
        company_name: lead.company_name,
        address: lead.address,
        city: lead.city,
        zip_code: lead.zip_code,
        head_count: lead.head_count,
        legal_structure: lead.legal_structure,
        creation_date: lead.creation_date,
        ongoing_recruitments: lead.recruitments.count
      }
      json_leads[:leads] << json_lead
    end
    return json_leads
  end
end

