namespace :recruitmentvj do
  desc "récupérer les recrutements sur vj et les écrire en base"
  # rails recruitmentvj:fetch_recruitmentvjs
  task fetch_recruitmentvjs: :environment do

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
      # cat = Category.find_by(name: "Avocat")
      # input.category = cat
      input.company = create_company(recruitoffer)
      if input.save
        @nb_create +=1
      end
    end

    def create_company(recruitoffer)
      company = Company.find_by(recruitoffer[:external_id])
      if company
        company
      else
        # création rapide de la company
        new_company = Company.create!(
          company_name: recruitoffer["company_name"],
          siret: recruitoffer["siret"],
          siren: recruitoffer["siren"],
          naf_code: "69.10Z",
          zip_code: recruitoffer["zip_code"],
          city: recruitoffer["city"],
          category_id: Category.find_by(name: "Avocat").id
        )
        # enrichissement de la company
        APIPapers.new.papers_one(new_company.siret)
        return new_company
      end
    end

    def update_recruitment(recruitoffer)
      input = Recruitment.find_by(recruitoffer[:external_id])
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

    def run_vj
      data = ScrapVj.new.get_vj_recruit_offers
      #p data
      @nb_update = 0
      @nb_create = 0
      data.each do |recruitoffer|
        #p recruitoffer[:external_id]

        if Recruitment.find_by(recruitoffer[:external_id])
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

    run_vj

  end
end
