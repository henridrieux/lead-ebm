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
      cat = Category.find_by(name: "Notaire")
      input.category = cat
      # clean employer name
      office_name = input[:employer].split.select { |v| v == v.upcase && !EXCEPTIONS.include?(v)}.first
      list_of_zip_code = Company.where(zip_code: recruitoffer["zipCode"], category: cat)
      if list_of_zip_code.where("company_name like ?", "%#{office_name}%" )
        company_to_match = list_of_zip_code.where("company_name like ?", "%#{office_name}%" ).first
        input.company = company_to_match
        # company_to_match.category = Category.find_by(name: "Notaire")
        # company_to_match.save
      elsif list_of_zip_code.count == 1
        input.company = list_of_zip_code.first
      end
      # p input.company_id if input.company
      if input.save
        @nb_create +=1
      end
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
      cat = Category.find_by(name: "Notaire")
      office_name = input[:employer].split.select { |v| v == v.upcase && !EXCEPTIONS.include?(v)}.first
      list_of_zip_code = Company.where(zip_code: recruitoffer["zipCode"], category: cat)
      if list_of_zip_code.where("company_name like ?", "%#{office_name}%" )
        p input.company = list_of_zip_code.where("company_name like ?", "%#{office_name}%" ).first
      elsif list_of_zip_code.count == 1
        input.company = list_of_zip_code.first
      end
      # p input.company_id if input.company
      input.save
    end

    def run_bourse_emploi(number)
      data = APIBourseEmploi.new.bourse_emploi(number)
      @nb_update = 0
      @nb_create = 0
      data.each do |recruitoffer|
        # p Recruitment.find_by(external_id: recruitoffer["idOffer"])
        if Recruitment.find_by(external_id: recruitoffer["idOffer"])
          update_recruitment(recruitoffer)
          p "emploi updated"
          @nb_update +=1
        else
          create_recruitment(recruitoffer)
          p "emploi created"
        end
      end
      puts "#{@nb_create} créations et #{@nb_update} updates"
    end

    run_bourse_emploi(200)
  end
end
