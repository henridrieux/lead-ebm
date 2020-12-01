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
      input.company = create_company(recruitoffer)
      if input.save
        @nb_create +=1
      end
    end


    def create_company(recruitoffer)
      company = Company.find_by(siret: recruitoffer["siret"])
      if company
        company
      else
        new_company = Company.create!(
          company_name: recruitoffer["officeName"],
          siret: recruitoffer["siret"],
          siren: recruitoffer["siren"],
          naf_code: "69.10Z",
          zip_code: recruitoffer["zipCode"],
          city: recruitoffer["city"],
          category_id: Category.find_by(name: "Notaire").id,
        )
        return new_company
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
      input.save
    end

    def run_bourse_emploi(number)
      data = APIBourseEmploiNew.new.bourse_emploi(number)
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

    run_bourse_emploi(2)
  end
end
