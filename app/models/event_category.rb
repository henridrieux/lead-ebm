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

  def leads_number
    self.get_company_leads.count
  end

  def slack_json_leads
    leads = self.get_company_leads
    slack_leads = []
    leads.each do |lead|
      lead_slack = {
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*#{self.category.name} - #{self.event.title}*🤑"
            }
          },
          {
            "type": "section",
            "fields": [
              {
                "type": "plain_text",
                "text": "*#{lead.company_name}*",
                "emoji": true
              },
              {
                "type": "plain_text",
                "text": "📆créé le #{lead.creation_date}",
                "emoji": true
              },
              {
                "type": "plain_text",
                "text": "🏢#{lead.address} - #{lead.zip_code} #{lead.city}",
                "emoji": true
              },
              {
                "type": "plain_text",
                "text": "#{lead.recruitments.count}🤝 recrutements en cours",
                "emoji": true
              },
              {
                "type": "plain_text",
                "text": "🧑‍🤝‍🧑#{lead.head_count} - #{lead.legal_structure}",
                "emoji": true
              }
            ]
          }
        ]
      }
      slack_leads << lead_slack
    end
    return slack_leads
  end
end

