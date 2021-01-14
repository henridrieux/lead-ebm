class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  has_many :companies, through: :category
  has_many :recruitments, through: :categories
  has_many :subscriptions
  validates :title, presence: true

  validates :category, uniqueness: { scope: :event, message: "can't be associated twice to the same event" }

  def get_company_leads
      query_params = " \
      #{Date.today - self.event.query_params.to_i } \
      "
      @leads = get_company_leads_from_date(query_params)
    return @leads
  end

  def get_company_leads_from_date(date)
      query = self.event.query
      query_params = "#{date}"
    if self.event.title == "Sociétés qui recrutent"
      companies = Company.joins(:recruitments)
      companies = companies.where("companies.category_id = #{self.category_id}")
      rec_companies = companies ? companies.where(query, query_params) : nil
      @leads = rec_companies.uniq
    else
      companies = Company.includes(:category, :events, :recruitments).where(category: self.category)
      @leads = companies ? companies.where(query, query_params) : nil
      @leads = @leads.order(creation_date: :desc)
    end
    return @leads
  end

  def get_new_leads
    @new_leads = self.get_company_leads_from_date(Date.today-1)
    return @new_leads
  end

  def leads_number
    self.get_company_leads.count
  end

  def slack_json_leads
    leads = self.get_new_leads
    slack_leads = []
    leads.each do |lead|
      lead_slack = {
        "blocks": [

      #     {
      #       "type": "header",
      #       "text": {
      #         "type": "plain_text",
      #         "text": "#{lead.company_name}"
      #       }
      #     },
      #     {
      #       "type": "divider"
      #     },
      #     {
      #       "type": "section",
      #       "fields": [
      #         {
      #           "type": "mrkdwn",
      #           "text": "*Company legal*\n📆Créé le #{lead.creation_date}\n🌇#{lead.zip_code} #{lead.city}\n🏢#{lead.legal_structure}\n🧑‍🤝‍🧑#{lead.head_count}"
      #         },
      #         {
      #           "type": "mrkdwn",
      #           "text": "*Company info*\n#{lead.recruitments.count}🤝 recrutements en cours\n💻#{lead.website}\n💌#{lead.email}"
      #         }
      #       ]
      #     },
      #     {
      #       "type": "header",
      #       "text": {
      #         "type": "plain_text",
      #         "text": "*#{self.category.name} - #{self.event.title} 🤑"
      #       }
      #     },
      #     {
      #       "type": "input",
      #       "element": {
      #         "type": "multi_users_select",
      #         "placeholder": {
      #           "type": "plain_text",
      #           "text": "Select users",
      #           "emoji": true
      #         },
      #         "action_id": "multi_users_select-action"
      #       },
      #       "label": {
      #         "type": "plain_text",
      #         "text": "Label",
      #         "emoji": true
      #       }
      #     },
      #     {
      #       "type": "actions",
      #       "elements": [
      #         {
      #           "type": "button",
      #           "text": {
      #             "type": "plain_text",
      #             "text": "Traité",
      #             "emoji": true
      #           },
      #           "style": "primary",
      #           "value": "approve"
      #         },
      #         {
      #           "type": "button",
      #           "text": {
      #             "type": "plain_text",
      #             "text": "Refusé",
      #             "emoji": true
      #           },
      #           "style": "danger",
      #           "value": "decline"
      #         },
      #         {
      #           "type": "button",
      #           "text": {
      #             "type": "plain_text",
      #             "text": "View Details",
      #             "emoji": true
      #           },
      #           "value": "click_me_123",
      #           "url": "https://www.leadseventdata.club/dashboard",
      #           "action_id": "button-action"
      #         }
      #       ]
      #     },
      #     {
      #       "type": "divider"
      #     }
      #   ]
      # }

         # _____________________

          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*#{self.category.name} - #{self.event.title} - #{lead.company_name}*🤑"
            }
          },
          # {
          #   "type": "section",
          #   "fields": [
          #     {
          #       "type": "plain_text",
          #       "text": "#{lead.company_name}",
          #       "emoji": true
          #     },
          #     {
          #       "type": "plain_text",
          #       "text": "📆créé le #{lead.creation_date}",
          #       "emoji": true
          #     },
          #     {
          #       "type": "plain_text",
          #       "text": "🏢#{lead.address} - #{lead.zip_code} #{lead.city}",
          #       "emoji": true
          #     },
          #     {
          #       "type": "plain_text",
          #       "text": "#{lead.recruitments.count}🤝 recrutements en cours",
          #       "emoji": true
          #     },
          #     {
          #       "type": "plain_text",
          #       "text": "🧑‍🤝‍🧑#{lead.head_count} - #{lead.legal_structure}",
          #       "emoji": true
          #     },
          #     {
          #       "type": "plain_text",
          #       "text": "💻#{lead.website} - 💌#{lead.email}",
          #       "emoji": true
          #     }
          #   ]
          # },
          # {
          #   "type": "divider"
          # },
          {
            "type": "section",
            "fields": [
              {
                "type": "mrkdwn",
                "text": "*Company legal*\n📆Créé le #{lead.creation_date}\n🌇#{lead.zip_code} #{lead.city}\n🏢#{lead.legal_structure}\n🧑‍🤝‍🧑#{lead.head_count}"
              },
              {
                "type": "mrkdwn",
                "text": "*Company info*\n#{lead.recruitments.count}🤝 recrutements en cours\n💻#{lead.website}\n💌#{lead.email}"
              }
            ]
          },
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "Traité",
                  "emoji": true
                },
                "style": "primary",
                "value": "approve"
              },
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "Refusé",
                  "emoji": true
                },
                "style": "danger",
                "value": "decline"
              },
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "View Details",
                  "emoji": true
                },
                "value": "click_me_123",
                "url": "https://www.leadseventdata.club/dashboard",
                "action_id": "button-action"
              }
            ]
          },
          {
            "type": "actions",
            "elements": [
              {
                "type": "radio_buttons",
                "options": [
                  {
                    "text": {
                      "type": "plain_text",
                      "text": "*this is plain_text text*",
                      "emoji": true
                    },
                    "value": "value-0"
                  },
                  {
                    "text": {
                      "type": "plain_text",
                      "text": "*this is plain_text text*",
                      "emoji": true
                    },
                    "value": "value-1"
                  }
                ],
                "action_id": "actionId-0"
              }
            ]
          },
          {
            "type": "divider"
          }
        ]
      }
      slack_leads << lead_slack
    end
    return slack_leads
  end

  def slack_welcome
      core_message = "Vous venez de vous abonner à notre évènement : #{self.event.title} \
pour le métier #{self.category.name}. Vous recevrez vos premiers L.E.A.D. dès demain matin. 🚀"
      new_sub_slack = {
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*#{self.category.name} => #{self.event.title}*"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "plain_text",
              "text": "#{core_message}",
              "emoji": true
            }
          }
        ]
      }
    return new_sub_slack
  end

end

