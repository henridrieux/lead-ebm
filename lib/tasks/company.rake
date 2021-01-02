namespace :company do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company:fetch_compagnies
  task fetch_compagnies: :environment do

    def run_papers(number, date_string)
      APIPapers.new.papers_all(number, date_string)
      #APIPapers6920z.new.papers_all(number, date_string)
    end
    run_papers(10000, "01-01-1950")
  end

  # rails company:fetch_one_company
  task fetch_one_company: :environment do

    def run_one_paper(siret_string)
      APIPapers.new.papers_one(siret_string)
    end

    # run_one_paper("52503152201109")
  end

  # rails company:push_leads_to_slack
  task push_leads_to_slack: :environment do
    User.all.each do |user|
      if user.webhook_slack?
        # p user.event_categories.count
        user.event_categories.each do |event_cat|
          NotifySlack.new.perform(event_cat, user.webhook_slack)
        end
      end
    end
  end

end
