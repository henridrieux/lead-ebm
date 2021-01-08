namespace :recruitmentarchi do
  desc "récupérer les recrutements sur ordre des archis et les écrire en base"
  # rails recruitmentarchi:fetch_recruitmentsarchi
  task fetch_recruitmentsarchi: :environment do

  ScrapArchi.new.create_archi_recruitment

  end
end


