namespace :recruitmentcomptajob do
  desc "récupérer les recrutements sur comptajob et les écrire en base"
  # rails recruitmentcomptajob:fetch_recruitmentscomptajob
  task fetch_recruitmentscomptajob: :environment do
    ScrapCompta.new.create_comptajob_recruitment
  end
end
