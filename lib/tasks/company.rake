namespace :company do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company:fetch_compagnies
  task fetch_compagnies: :environment do

    def run_papers(number, date_string)
      APIPapers.new.papers_all(number, date_string)
    end

    run_papers(400, "01-09-2020")
  end

  # rails company:fetch_one_company
  task fetch_one_company: :environment do

    def run_one_paper(siret_string)
      APIPapers.new.papers_one(siret_string)
    end

    run_one_paper("89061007400019")
  end

  # rails company:push_leads_to_slack
  task push_leads_to_slack: :environment do
    cat = Category.find_by(name: "Avocat")
    event = Event.find_by(title: "Les créations de société")
    event_cat = EventCategory.find_by(category: cat, event: event)
    NotifySlack.new.perform(event_cat)
   #  EventCategory.first.each do |event_category|
   #    APIBourseEmploi.new.post_to_slack(event_category)
   # end
  end
end
