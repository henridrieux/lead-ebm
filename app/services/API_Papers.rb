require 'httparty'

class APIPapers
# Or wrap things up in your own class

require "json"

  def papers_all(number, date_string)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        par_page: number,
        entreprise_cessee: false,
        nom_entreprise: "",
        code_naf: "69.10Z",
        date_creation_min: date_string
      },
      headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
      },
      body: body_request.to_json
    }
    return_body= HTTParty.get(url, @options).body
    result = JSON.parse(return_body)
    @nb_create = 0
    @nb_update = 0
    nb_request = result["entreprises"].count
    result["entreprises"].each do |v|
      company = transform_json(v["siege"]["siret"])
      check_company(company)
      nb_treated = @nb_create + @nb_update
      puts " #{nb_treated} / #{nb_request} - #{((nb_treated / nb_request.to_f)*100).round}%"
    end
    puts "#{@nb_create} créations et #{@nb_update} updates"
  end

  def papers_one(siret)
    @nb_create = 0
    @nb_update = 0
    company = transform_json(siret)
    check_company(company)
    puts "#{@nb_create} création et #{@nb_update} update"
    p Company.find_by(siret: siret.to_i)
  end

  def transform_json(siret)
    url2 = "https://api.pappers.fr/v1/entreprise?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        siret: "#{siret}"
      },
      headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
      },
      body: body_request.to_json
    }
    return_body_siret = HTTParty.get(url2, @options).read_body
    result2 = JSON.parse(return_body_siret)
    # p result2
    return result2
  end

  def check_company(company)
    Company.find_by(siret: company["siege"]["siret"].to_i)
    if Company.find_by(siret: company["siege"]["siret"].to_i)
      update_company(company)
      @nb_update += 1
    else
      create_company(company)
      @nb_create += 1
    end
  end

  def create_company(company)
    input2 = Company.new(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      company_name: company["nom_entreprise"],
      social_purpose: company["objet_social"],
      creation_date: company["siege"]["date_de_creation"],
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

    cat = check_category(input2)
    input2.category = Category.find_by(name: cat)
    input2.save
  end

  def test_category(input, keyword, cat_name)
    test = false
    test1 = input.company_name.match?(/.*#{keyword}.*/i)
    test2 = input.activities.match?(/.*#{keyword}.*/i) if input.activities
    test3 = input.social_purpose.match?(/.*#{keyword}.*/i) if input.social_purpose
    test = test1 |  test2 || test3
  end

  def check_category (input)
    cat = "Notaire"
    prof_test = {
      "Administrateur judiciaire" => "administrateur",
      "Comptable" => "compta",
      "Commissaire-priseur" => "commissaire",
      "Greffier" => "greffier",
      "Avocat" => "avocat",
      "Huissier" => "huissier"
    }
    prof_test.each do |k,v|
      cat = k if test_category(input, v, k)
    end
    p cat
    return cat
  end

  def update_company(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    address_old = input2[:address]
    address_new = company["siege"]["adresse_ligne_1"]
    if address_old != address_new
      last_moving_date = Date.today
      puts "1 address has changed"
    else
      last_moving_date = input2[:last_moving_date]
    end
    input2.update(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      company_name: company["nom_entreprise"],
      social_purpose: company["objet_social"],
      creation_date: company["siege"]["date_de_creation"],
      registered_capital: company["capital"].to_i,
      address: company["siege"]["adresse_ligne_1"],
      zip_code: company["siege"]["code_postal"],
      city: company["siege"]["ville"],
      last_moving_date: last_moving_date,
      legal_structure: company["forme_juridique"],
      # manager_name: company["representants"].first["nom_complet"],
      # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
      head_count: company["effectif"],
      naf_code: company["siege"]["code_naf"],
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
    )
    cat = check_category(input2)
    input2.category = Category.find_by(name: cat)
    input2.save
  end

end
