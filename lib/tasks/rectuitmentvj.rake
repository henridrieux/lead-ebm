namespace :recruitmentvj do
  desc "récupérer les recrutements sur vj et les écrire en base"
  # rails recruitmentvj:fetch_recruitmentvjs
  task fetch_recruitmentvjs: :environment do

    #test

  ScrapVj.new.create_vj_recruitment

  end
end
