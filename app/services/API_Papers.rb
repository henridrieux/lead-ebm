# _________ PROFESSIONS JURIDIQUES ___________

require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'
require 'clearbit'
require "uri"
require 'httparty'
require "net/http"

class APIPapers
# Pour populer la partie recruitmnet = papersone

  def papers_one(siret)
    @nb_create = 0
    @nb_update = 0
    company = transform_json(siret)
    companyfull = update_company(company)

    # if Company.find_by(siret: siret.to_i)
    #   update_company_adress(company)
    #   update_company_siret_counter(company)
    #   check_company_manager_name(company)
    #   check_company_website(company)
    # end
    #puts "#{@nb_create} création et #{@nb_update} update"
    # p Company.find_by(siret: siret.to_i)
  end

  def papers_all(number, date_string)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        par_page: number,
        entreprise_cessee: false,
        code_naf: "69.10Z",
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
    return_body = HTTParty.get(url, @options).body
    result = JSON.parse(return_body)
    result["entreprises"].count
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

  def check_company(company)
    #Company.find_by(siret: company["siege"]["siret"].to_i)
    if Company.find_by(siret: company["siege"]["siret"].to_i)
      update_company_adress(company)
      update_company_siret_counter(company)
      check_company_manager_name(company)
      check_company_website(company)
      @nb_update += 1
    else
      create_company(company)
      @nb_create += 1
    end
  end

  def headquarter_count(siren)
    apitoken = "3e10f34b388926a0e4030180829391e02b3155bef5f069d5"
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=#{apitoken}&siren=#{siren}&entreprise_cessee=false")
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
      # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
      head_count: company["effectif"],
      naf_code: company["siege"]["code_naf"],
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
    )
    if company["representants"].count == 0
      input2.manager_name = "N.C."
    else
      input2.manager_name = company["representants"].first["nom_complet"]
    end
    cat = check_category(input2)
    # p cat
    input2.category = Category.find_by(name: cat)
    # p input2.category
    input2.website = http(input2["siren"], cat)
    input2.email = email(input2["siren"], cat)
    # if input2.email == "N.C."
    #   p "clearbit test"
    #   input2.email = clearbit(input2.website)
    # end
    input2.save
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
      "Huissier" => "huissier",
      "Avocat" => "avocat",
      "Notaire" => "nota"
    }
    prof_test.each do |k, v|
      cat = k if test_category(input, v, k)
    end

    if cat == "Greffier"
      check_category_greffier(input.siren, input.city)
    end
    #p cat
    return cat
  end

  def update_company(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
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
      legal_structure: company["forme_juridique"],
      head_count: company["effectif"],
      naf_code: company["siege"]["code_naf"],
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
    )
    cat = "Notaire"
    input2.category = Category.find_by(name: cat)
    input2.save
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
      address: company["siege"]["adresse_ligne_1"],
      zip_code: company["siege"]["code_postal"],
      city: company["siege"]["ville"],
      last_moving_date: last_moving_date,
    )
    input2.save
  end

  def update_company_siret_counter(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    siret_count_old = input2[:siret_count]
    siret_count_new = headquarter_count(company["siren"])

    if siret_count_old != siret_count_new && !siret_count_old.nil?
      second_headquarter_date = Date.today
      puts "1 nouvel établissement"
    else
      second_headquarter_date = input2[:second_headquarter_date]
    end
    input2.update(
      siret_count: headquarter_count(company["siren"].to_i),
      second_headquarter_date: second_headquarter_date,
    )
    input2.save
  end

  def check_company_manager_name(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    manager_name_old = input2[:manager_name]

    if company["representants"].count == 0
      manager_name_new = "N.C."
    else
      manager_name_new = company["representants"].first["nom_complet"]
    end

    if manager_name_old != manager_name_new && !manager_name_old.nil?
      fusion_date = Date.today
      puts "1 changement de dirigeant"
    else
      fusion_date = input2[:fusion_date]
    end
    input2.update(
      fusion_date: fusion_date
    )

    if company["representants"].count == 0
      input2.manager_name = "N.C."
    else
      input2.manager_name = company["representants"].first["nom_complet"]
    end
    input2.save
  end

  def check_company_website(company)
    input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
    website_old = input2[:website]
    cat = check_category(input2)
    website_new = http(company["siren"], cat)

    if website_old != website_new && !website_old.nil?
      website_date = Date.today
      puts "1 création de site web"
    else
      website_date = input2[:website_date]
    end

    input2.update(
      website: website_new,
      website_date: website_date
    )
    input2.save
  end

  def website(siren)
    apitoken = "3e10f34b388926a0e4030180829391e02b3155bef5f069d5"
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=#{apitoken}&siren=#{siren}&entreprise_cessee=false")
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
    cat = category
    url = URI("https://www.google.com/search?q=#{query} #{cat}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
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
      #p url
      if url.match(domain_regex)
        array << url
      else
        bin << url
      end
    end

    array2 = array.first(6)
    bin2 = []
    array3 = []
    array2.each do |url|

      # URL GOOGLE

      domain_map = /(https)\:\/\/maps[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_google = /(https)\:\/\/www\.googl[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL CLASSIQUE

      domain_societe = /(\/url\?q=)(https)\:\/\/www\.soci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_pagesjaunes = /(\/url\?q=)(https)\:\/\/www\.pages[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_linkedin = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_mappy = /(\/url\?q=)(https)\:\/\/fr\.map[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_facebook = /(\/url\?q=)(https)\:\/\/fr-fr\.faceboo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_facebook2 = /(\/url\?q=)(https)\:\/\/www\.face[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_verif = /(\/url\?q=)(https)\:\/\/www\.veri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_lefi = /(\/url\?q=)(http)\:\/\/entreprises\.lefiga[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_info = /(\/url\?q=)(http)\:\/\/www\.greffe[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_info2 = /(\/url\?q=)(https)\:\/\/www\.infogreff[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_actu = /(\/url\?q=)(https)\:\/\/actulegale[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_irish = /(\/url\?q=)(https)\:\/\/www\.irishtim[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/


      # URL AVOCAT
      domain_lille = /(\/url\?q=)(https)\:\/\/www\.avocats-lill[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_consultation = /(\/url\?q=)(https)\:\/\/consultation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_annuaireacte = /(\/url\?q=)(http)\:\/\/annuaire[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL NOTAIRE

      # domain_notaire = /(\/url\?q=)(https)\:\/\/www\.notair[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_immo = /(\/url\?q=)(https)\:\/\/www\.immono[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_immonot = /(\/url\?q=)(https)\:\/\/www\.immobilier\.notai[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      # URL MEDECIN

      domain_docto = /(\/url\?q=)(http)\:\/\/doctoli[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto2 = /(\/url\?q=)(https)\:\/\/www\.docto[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_rdvmedi = /(\/url\?q=)(https)\:\/\/www.rdvmedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docave = /(\/url\?q=)(https)\:\/\/www.docave[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_keldoc = /(\/url\?q=)(https)\:\/\/www.keldo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_lemedecin = /(\/url\?q=)(https)\:\/\/lemedeci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      if url.match(domain_irish) || url.match(domain_actu) || url.match(domain_lille) || url.match(domain_info2) || url.match(domain_info) || url.match(domain_immonot) || url.match(domain_lefi) || url.match(domain_immo) || url.match(domain_mappy) || url.match(domain_verif) || url.match(domain_lemedecin) || url.match(domain_docto2) || url.match(domain_docto) || url.match(domain_rdvmedi) || url.match(domain_docave) || url.match(domain_keldoc) || url.match(domain_facebook2) || url.match(domain_facebook) || url.match(domain_annuaireacte) || url.match(domain_google) || url.match(domain_map) || url.match(domain_societe) || url.match(domain_pagesjaunes) || url.match(domain_linkedin) || url.match(domain_consultation) || url.match(domain_doctrine)
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
    #p url
    return url
  end

  def email(siren, category)
    if http(siren, category).nil?
      email_address = "N.C."
    else
      url = http(siren, category)
      p url
      html_file = open(url).read
      if html_file.nil? || html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).nil?
        email_address = "N.C."
      else
        email_address = html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0].to_s
      end
      return email_address
    end
  end

  # def clearbit(website)

  #   url = URI("https://company.clearbit.com/v2/companies/find?domain=#{website}")

  #   https = Net::HTTP.new(url.host, url.port)
  #   https.use_ssl = true
  #   request = Net::HTTP::Get.new(url)
  #   request["Authorization"] = ENV['CLEARBIT_KEY']
  #   response = https.request(request)
  #   puts response.read_body["site"]["emailAddresses"]
  # end

  def check_category_greffier(siren, city)
    query = website(siren)
    cityquery = city
    url = URI("https://www.google.com/search?q=#{query} #{cityquery}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
    html_file = open(url).read

    # if html_file.match?(/[a-zA-Z0-9\-\.]dministrateu[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]ommissair[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]uissie[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]otaire[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]voca[a-zA-Z0-9\-\.](\/\S*)?/i).nil?
    if html_file.match?(/[a-zA-Z0-9\-\.]dministrateu[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Administrateur judiciaire"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]ommissair[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Commissaire-priseur"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]uissie[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Huissier"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]otaire[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Notaire"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]voca[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Avocat"
    else
      cat = "Greffier"
    end
    # p cat
    return cat
  end
end

#APIPapers.new.papers_all(10, "01-01-1900")
