namespace :recruitmenthubemploi do
  desc "récupérer les recrutements sur vj et les écrire en base"
  # rails recruitmenthubemploi:fetch_recruitmentshubemploi
  task fetch_recruitmentshubemploi: :environment do

  ScrapHubemploi.new.create_hubemploi_recruitment

  end
end

