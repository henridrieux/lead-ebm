require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'

class APIPapers8030z
# Or wrap things up in your own class

  def papers_all(number, date_string)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        par_page: number,
        entreprise_cessee: false,
        code_naf: "80.30Z",
        #effectif_min: 2,
        departement: 75,
        date_creation_min: date_string
      },
       headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
      },
      body: body_request.to_json
    }

    body_request
    return_body = HTTParty.get(url, @options).body
    result = JSON.parse(return_body)
    @nb_create = 0
    @nb_update = 0
    nb_request = result["entreprises"].count
    result["entreprises"].each do |v|
      company = transform_json(v["siege"]["siret"])
      check_company_adress(company)
      check_company_siret_counter(company)
      nb_treated = @nb_create + @nb_update
      # puts " #{nb_treated} / #{nb_request} - #{((nb_treated / nb_request.to_f)*100).round}%"
    end
    # puts "#{@nb_create} créations et #{@nb_update} updates"
  end

  def papers_one(siret)
    @nb_create = 0
    @nb_update = 0
    company = transform_json(siret)
    check_company_adress(company)
    # puts "#{@nb_create} création et #{@nb_update} update"
    # p Company.find_by(siret: siret.to_i)
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
    #p result2
    return result2
  end

  def check_company_adress(company)
    Company.find_by(siret: company["siege"]["siret"].to_i)
    if Company.find_by(siret: company["siege"]["siret"].to_i)
      update_company_adress(company)
      @nb_update += 1
    else
      create_company(company)
      @nb_create += 1
    end
  end

  def check_company_siret_counter(company)
    Company.find_by(siret: company["siege"]["siret"].to_i)
    if Company.find_by(siret: company["siege"]["siret"].to_i)
      update_company_siret_counter(company)
    else
      create_company(company)
    end
  end

  def headquarter_count(siren)
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&siren=#{siren}&entreprise_cessee=false")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)
    return result["etablissements"].count
  end

  def create_company(company)
    input2 = Company.new(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      siret_count: headquarter_count(company["siren"].to_i),
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
    input2.website = http(input2["siren"], cat)
    input2.email = email(input2["siren"], cat)
    # p input2.email
    input2.save
    #p input2
  end

  def test_category(input, keyword, cat_name)
    test = false
    test1 = input.company_name.match?(/.*#{keyword}.*/i)
    test2 = input.activities.match?(/.*#{keyword}.*/i) if input.activities
    test3 = input.social_purpose.match?(/.*#{keyword}.*/i) if input.social_purpose
    test = test1 || test2 || test3
  end

  def check_category(input)
    cat = "Greffier"
    if input.category && input.category == Category.find_by(name: "Notaire")
      cat = "Notaire"
    end
    prof_test = {
      "Administrateur judiciaire" => "administrateur",
      "Commissaire-priseur" => "commissaire",
      "Greffier" => "greffier",
      "Avocat" => "avocat",
      "Huissier" => "huissier",
      "Notaire" => "nota"
    }
    prof_test.each do |k, v|
      cat = k if test_category(input, v, k)
    end

    # p cat
    return cat
  end

  def update_company_adress(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    address_old = input2[:address]
    address_new = company["siege"]["adresse_ligne_1"]
    if address_old != address_new && !address_old.nil?
      last_moving_date = Date.today
      puts "1 address has changed"
    else
      last_moving_date = input2[:last_moving_date]
    end

    input2.update(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      siret_count: headquarter_count(company["siren"].to_i),
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
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"],
    )

    cat = check_category(input2)
    input2.category = Category.find_by(name: cat)
    input2.website = http(input2["siren"], cat)
    input2.email = email(input2["siren"], cat)
    input2.save
    # p input2
  end

  def update_company_siret_counter(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    siret_count_old = input2[:siret_count]
    siret_count_new = company["siege"]["siret_count"]
    if siret_count_old != siret_count_new && !siret_count_old.nil?
      second_headquarter_date = Date.today
      puts "1 nouvel établissement"
    else
      second_headquarter_date = input2[:second_headquarter_date]
    end
    input2.update(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      siret_count: headquarter_count(company["siren"].to_i),
      company_name: company["nom_entreprise"],
      social_purpose: company["objet_social"],
      creation_date: company["siege"]["date_de_creation"],
      registered_capital: company["capital"].to_i,
      address: company["siege"]["adresse_ligne_1"],
      zip_code: company["siege"]["code_postal"],
      city: company["siege"]["ville"],
      # last_moving_date: last_moving_date,
      second_headquarter_date: second_headquarter_date,
      legal_structure: company["forme_juridique"],
      # manager_name: company["representants"].first["nom_complet"],
      # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
      head_count: company["effectif"],
      naf_code: company["siege"]["code_naf"],
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
    )

    cat = check_category(input2)
    input2.category = Category.find_by(name: cat)
    input2.website = http(input2["siren"], cat)
    input2.email = email(input2["siren"], cat)
    input2.save
  end

  # __________________________________

  def website(siren)
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&siren=#{siren}&entreprise_cessee=false")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)
    result = result["nom_entreprise"] + " " + result["siege"]["ville"]
    # p result
    return result
  end

  def check_google(siren, category)
    query = website(siren)
    categ = " detective"
    url = URI("https://www.google.com/search?q=#{query}#{categ}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
    # p url
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    links = html_doc.search('a')
    urls = links.map { |a| a.attribute("href").value }
    return urls
  end

  def http(siren, category)
    array = []
    bin = []
    domain_regex = /(http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    check_google(siren, category).each do |url|
      # p url
      if url.match(domain_regex)
        array << url
      else
        bin << url
      end
    end

    array2 = array.first(12)
    bin2 = []
    array3 = []
    array2.each do |url|

      # URL GOOGLE

      domain_map = /(https)\:\/\/maps[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_google = /(https)\:\/\/www\.googl[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_google2 = /(http)\:\/\/www\.googl[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL CLASSIQUE

      #domain_societe = /(\/url\?q=)(https)\:\/\/www\.soci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_pagesjaunes = /(\/url\?q=)(https)\:\/\/www\.pages[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_linkedin = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_mappy = /(\/url\?q=)(https)\:\/\/fr\.map[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_facebook = /(\/url\?q=)(https)\:\/\/fr-fr\.faceboo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_facebook2 = /(\/url\?q=)(https)\:\/\/www\.face[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_info = /(\/url\?q=)(https)\:\/\/www\.infogreff[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_kompas = /(\/url\?q=)(https)\:\/\/fr\.kompas[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_groupe = /(\/url\?q=)(https)\:\/\/www\.groupe-spel[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_erf = /(\/url\?q=)(https)\:\/\/erf-dete[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_rci = /(\/url\?q=)(http)\:\/\/rci-detec[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_rif = /(\/url\?q=)(http)\:\/\/detective-r[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_cnaps = /(\/url\?q=)(http)\:\/\/www\.cnap[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_dete = /(\/url\?q=)(https)\:\/\/detective-prive.annuairefranc[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL AVOCAT

      # domain_consultation = /(\/url\?q=)(https)\:\/\/consultation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_annuaireacte = /(\/url\?q=)(http)\:\/\/annuaire[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL NOTAIRE

      # domain_notaire = /(\/url\?q=)(https)\:\/\/www\.notair[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_immo = /(\/url\?q=)(https)\:\/\/entreprise[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_immo = /(\/url\?q=)(http)\:\/\/entreprise[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL MEDECIN

      # domain_docto = /(\/url\?q=)(http)\:\/\/doctoli[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto2 = /(\/url\?q=)(https)\:\/\/www\.mondoct[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_rdvmedi = /(\/url\?q=)(https)\:\/\/www.rdvmedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_docave = /(\/url\?q=)(https)\:\/\/www.docave[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # domain_keldoc = /(\/url\?q=)(https)\:\/\/www.keldo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/


      if url.match(domain_dete) || url.match(domain_cnaps) || url.match(domain_rif) || url.match(domain_rci) || url.match(domain_erf) || url.match(domain_groupe) || url.match(domain_kompas) || url.match(domain_docto2) || url.match(domain_info) || url.match(domain_google2) || url.match(domain_mappy) || url.match(domain_facebook2) || url.match(domain_facebook) || url.match(domain_google) || url.match(domain_map) || url.match(domain_linkedin)
        bin2 << url
      else
        array3 << url
      end
    end

    if array3.first.to_s.delete_prefix('/url?q=').split('&').nil?
      url = "N.C."
    else
      url = array3.first.to_s.delete_prefix('/url?q=').split('&').first
    end

    return url
  end

  def email(siren, category)

    if http(siren, category).nil? || http(siren, category) == "N.C."
      email_address = "N.C."
    else
      url = http(siren, category)
       p url
      html_file = open(url).read

      if html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).nil?
        email_address = "N.C."
      else
        email_address = html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0].to_s
      end
      return email_address
    end
  end

end

