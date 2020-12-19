namespace :company8030z do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company8030z:fetch_compagnies
  task fetch_compagnies: :environment do

    def run_papers(number, date_string)
      APIPapers8030z.new.papers_all(number, date_string)
    end
    run_papers(2000, "01-01-2015")
  end
end

