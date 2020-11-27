namespace :company do
  desc "récupérer les company sur Papers.com et les écrire en base"
  #rails company:fetch_compagnies
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
        # city: company["siege"]["ville"],
        legal_structure: company["forme_juridique"],
        # manager_name: company["representants"].first["nom_complet"],
        # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
        # head_count: company["effectif"],
        head_count: company["effectif"],
        naf_code: company["siege"]["code_naf"],
        activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
      )
      cat = "Notaire"
      test = false
      test1 = input2.company_name.match?(/.*avocat.*/i)
      test2 = input2.activities.match?(/.*avocat.*/i) if input2.activities
      test3 = input2.social_purpose.match?(/.*avocat.*/i) if input2.social_purpose
      test = test1 || test2 || test3
      if test
        cat = "Avocat"
      end
      input2.category = Category.find_by(name: cat)
      input2.save
    end

    def update_company(company)
      input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
      input2.update(
        siren: company["siren"].to_i,
        siret: company["siege"]["siret"].to_i,
        company_name: company["nom_entreprise"],
        social_purpose: company["objet_social"],
        creation_date: company["date_immatriculation_rcs"],
        registered_capital: company["capital"].to_i,
        address: company["siege"]["adresse_ligne_1"],
        zip_code: company["siege"]["code_postal"],
        # city: company["siege"]["ville"],
        legal_structure: company["forme_juridique"],
        # manager_name: company["representants"].first["nom_complet"],
        # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
        # head_count: company["effectif"],
        head_count: company["effectif"],
        naf_code: company["siege"]["code_naf"],
        activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
      )
    end

    def run_papers(number)
      data2 = APIPapers.new.papers
      data2.first(number).each do |company|
        p company["siege"]["siret"].to_i
        p Company.find_by(siret: company["siege"]["siret"].to_i)
        if Company.find_by(siret: company["siege"]["siret"].to_i)
          puts "try update 1"
          update_company(company)
        else
          puts "try create 1"
          create_company(company)
        end
      end
    end

    run_papers(30)
  end
end
