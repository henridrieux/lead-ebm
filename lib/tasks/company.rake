namespace :company do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company:fetch_compagnies
  task fetch_compagnies: :environment do
    def create_company(company)
      input2 = Company.new(
        siren: company["siren"].to_i,
        siret: company["siege"]["siret"].to_i,
        company_name: company["nom_entreprise"],
        social_purpose: company["objet_social"],
        creation_date: company["date_immatriculation_rcs"],
        registered_capital: company["capital"].to_i,
        address: company["siege"]["adresse_ligne_1"],
        zip_code: company["siege"]["code_postal"],
        city: company["siege"]["ville"],
        legal_structure: company["forme_juridique"],
        # manager_name: company["representants"].first["nom_complet"],
        # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
        head_count: company["effectif"],
        naf_code: company["siege"]["code_naf"],
        activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
      )

      cat = "Comptable"

      testavocat = false
      avocat1 = input2.company_name.match?(/.*avocat.*/i)
      avocat2 = input2.activities.match?(/.*avocat.*/i) if input2.activities
      avocat3 = input2.social_purpose.match?(/.*avocat.*/i) if input2.social_purpose
      testavocat = avocat1 || avocat2 || avocat3
      if testavocat
        cat = "Avocat"
      end

      testnotaire = false
      notaire1 = input2.company_name.match?(/.*nota.*/i)
      notaire2 = input2.activities.match?(/.*nota.*/i) if input2.activities
      notaire3 = input2.social_purpose.match?(/.*nota.*/i) if input2.social_purpose
      testnotaire = notaire1 || notaire2 || notaire3
      if testnotaire
        cat = "Notaire"
      end

      testhuissier = false
      huissier1 = input2.company_name.match?(/.*huissier.*/i)
      huissier2 = input2.activities.match?(/.*huissier.*/i) if input2.activities
      huissier3 = input2.social_purpose.match?(/.*huissier.*/i) if input2.social_purpose
      testnotaire = huissier1 || huissier2 || huissier3
      if testnotaire
        cat = "Huissier"
      end

      testadministrateur = false
      admin1 = input2.company_name.match?(/.*administrateur.*/i)
      admin2 = input2.activities.match?(/.*administrateur.*/i) if input2.activities
      admin3 = input2.social_purpose.match?(/.*administrateur.*/i) if input2.social_purpose
      testadministrateur = admin1 || admin2 || admin3
      if testadministrateur
        cat = "Administrateur judiciaire"
      end

      testcommissaire = false
      commissaire1 = input2.company_name.match?(/.*commissaire.*/i)
      commissaire2 = input2.activities.match?(/.*commissaire.*/i) if input2.activities
      commissaire3 = input2.social_purpose.match?(/.*commissaire.*/i) if input2.social_purpose
      testcommissaire = commissaire1 || commissaire2 || commissaire3
      if testcommissaire
        cat = "Commissaire-priseur"
      end

      input2.category = Category.find_by(name: cat)
      input2.save
    end

    def update_company(company)
      input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
      address_old = input2[:address]
      puts "address old"
      puts address_old
      input2.update(
        siren: company["siren"].to_i,
        siret: company["siege"]["siret"].to_i,
        company_name: company["nom_entreprise"],
        social_purpose: company["objet_social"],
        creation_date: company["date_immatriculation_rcs"],
        registered_capital: company["capital"].to_i,
        address: company["siege"]["adresse_ligne_1"],
        zip_code: company["siege"]["code_postal"],
        city: company["siege"]["ville"],
        legal_structure: company["forme_juridique"],
        # manager_name: company["representants"].first["nom_complet"],
        # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
        head_count: company["effectif"],
        naf_code: company["siege"]["code_naf"],
        activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
      )
      address_new = company["siege"]["adresse_ligne_1"]
      puts "address new"
      puts address_new
      puts "comparing adress"
        if address_old != address_new
          changed_adress = "Address has changed"
          puts changed_adress
          last_moving_date = Date.today
          puts last_moving_date
        else
          changed_adress = "Address has not changed"
          puts changed_adress
          last_moving_date = Date.today
          puts last_moving_date
        end
    end

    def run_papers(number)
      data2 = APIPapers.new.papers
      data2.first(number).each do |company|
        company["siege"]["siret"].to_i
        Company.find_by(siret: company["siege"]["siret"].to_i)
        if Company.find_by(siret: company["siege"]["siret"].to_i)
          puts "try update 1"
          update_company(company)
        else
          puts "try create 1"
          create_company(company)
        end
      end
    end

    run_papers(200)
  end

  # rails company:push_leads_to_slack
  task push_leads_to_slack: :environment do
    cat = Category.find_by(name: "Avocat")
    event = Event.find_by(title: "Les créations de société")
    event_cat = EventCategory.find_by(category: cat, event: event)
    p event_cat
    NotifySlack.new.post_to_slack(event_cat)
   #  EventCategory.first.each do |event_category|
   #    APIBourseEmploi.new.post_to_slack(event_category)
   # end
  end
end
