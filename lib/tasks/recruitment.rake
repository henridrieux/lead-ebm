namespace :recruitment do
  desc "récupérer les recrutements sur bourse_emploi et les écrire en base"
  # rails recruitment:fetch_recruitments
  task fetch_recruitments: :environment do
    def create_recruitment(recruitoffer)
      input = Recruitment.new(
        zip_code: recruitoffer["zipCode"].to_i,
        employer: recruitoffer["officeName"],
        job_title: recruitoffer["principal"],
        contract_type: recruitoffer["contractType"],
        publication_date: recruitoffer["datePublication"],
        employer_email: recruitoffer["mail"],
        job_description: recruitoffer["description"],
        employer_name: recruitoffer["label"],
        employer_phone: recruitoffer["phone"],
        external_id: recruitoffer["idOffer"]
      )
      input.category = Category.find_by(name: "Notaire")
      input.save
    end

    def update_recruitment(recruitoffer)
      input = Recruitment.find_by(external_id: recruitoffer["idOffer"])
      input.update(
        zip_code: recruitoffer["zipCode"].to_i,
        employer: recruitoffer["officeName"],
        job_title: recruitoffer["principal"],
        contract_type: recruitoffer["contractType"],
        publication_date: recruitoffer["datePublication"],
        employer_email: recruitoffer["mail"],
        job_description: recruitoffer["description"],
        employer_name: recruitoffer["label"],
        employer_phone: recruitoffer["phone"]
      )
    end

    def run_bourse_emploi(number)
      data = APIBourseEmploi.new.bourse_emploi
      data.first(number).each do |recruitoffer|
        # p recruitoffer["idOffer"]
        # p Recruitment.find_by(external_id: recruitoffer["idOffer"])
        if Recruitment.find_by(external_id: recruitoffer["idOffer"])
          # puts "try update 1"
          update_recruitment(recruitoffer)
        else
          # puts "try create 1"
          create_recruitment(recruitoffer)
        end
      end
    end

    run_bourse_emploi(1000)

  end

end
