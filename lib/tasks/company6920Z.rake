namespace :company6920Z do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company6920Z:fetch_compagnies
  task fetch_compagnies: :environment do

    def run_papers(number, date_string)
      APIPapers6920z.new.papers_all(number, date_string)
    end
    run_papers(3000, "01-01-1950")
  end

  # rails company:fetch_one_company
  task fetch_one_company: :environment do

    def run_one_paper(siret_string)
      APIPapers6920z.new.papers_one(siret_string)
    end

    run_one_paper("89061007400019")
  end

  # rails company:push_leads_to_slack
  task push_leads_to_slack: :environment do
    # cat = Category.find_by(name: "Avocat")
    # event = Event.find_by(title: "Créations de société ")
    # EventCategory.where(category: cat, event: event).each do |event_cat|
    User.all.each do |user|
      if user.webhook_slack?
        p user.event_categories.count
        user.event_categories.each do |event_cat|
          NotifySlack.new.perform(event_cat, user.webhook_slack)
        end
      end
    end
  end

end

