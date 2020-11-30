namespace :recruitment do
  desc "récupérer les recrutements sur bourse_emploi et les écrire en base"
  # rails recruitment:fetch_recruitments
  task fetch_recruitments: :environment do
    EXCEPTIONS = ["SAS", "SARL", "SELARL", "OFFICE", "NOTARIAL"]
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
      # clean employer name
      office_name = input[:employer].split.select { |v| v == v.upcase && !EXCEPTIONS.include?(v)}.first
      list_of_zip_code = Company.where(zip_code: recruitoffer["zipCode"])
      if list_of_zip_code.where("company_name like ?", "%#{office_name}%" )
        p input.company = list_of_zip_code.where("company_name like ?", "%#{office_name}%" ).first
      # elsif list_of_zip_code.count == 1
      #   p input.company = list_of_zip_code.first
      end
      # p input.company_id if input.company
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
      office_name = input[:employer].split.select { |v| v == v.upcase && !EXCEPTIONS.include?(v)}.first
      list_of_zip_code = Company.where(zip_code: recruitoffer["zipCode"])
      if list_of_zip_code.where("company_name like ?", "%#{office_name}%" )
        p input.company = list_of_zip_code.where("company_name like ?", "%#{office_name}%" ).first
      # elsif list_of_zip_code.count == 1
      #   p input.company = list_of_zip_code.first
      end
      # p input.company_id if input.company
      input.save
    end

    def run_bourse_emploi(number)
      data = APIBourseEmploi.new.bourse_emploi
      data.first(number).each do |recruitoffer|
        # p Recruitment.find_by(external_id: recruitoffer["idOffer"])
        if Recruitment.find_by(external_id: recruitoffer["idOffer"])
          update_recruitment(recruitoffer)
          p "emploi updated"
        else
          create_recruitment(recruitoffer)
          p "emploi created"
        end
      end
    end

    run_bourse_emploi(50)

  # rails recruitment:push_slack
  #task push_slack: :environment do
    #EventCategory.first.each do |event_category|
      #APIBourseEmploi.new.post_to_slack(EventCategory.find(9))
   # #end
  end
end
