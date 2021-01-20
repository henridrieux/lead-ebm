# _________ DETECTIVES PRIVEES ___________

require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'
require 'clearbit'
require "uri"
require "net/http"

class APIPapers8030z
# Or wrap things up in your own class

  def papers_all(number, date_string)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: ENV['PAPPERS_API_KEY'],
        par_page: number,
        entreprise_cessee: false,
        code_naf: "80.30Z",
        #effectif_min: 50,
        # departement: 75,
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
        api_token: ENV['PAPPERS_API_KEY'],
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
    Company.find_by(siren: company["siren"].to_i)
    if Company.find_by(siren: company["siren"].to_i)
      update_company_adress(company)
      @nb_update += 1
    else
      create_company(company)
      @nb_create += 1
    end
  end

  def check_company_siret_counter(company)
    Company.find_by(siren: company["siren"].to_i)
    if Company.find_by(siren: company["siren"].to_i)
      update_company_siret_counter(company)
    else
      create_company(company)
    end
  end

  def headquarter_count(siren)
    apitoken = ENV['PAPPERS_API_KEY']
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
    input2 = Company.find_by(siren: company["siren"].to_i)
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
    input2 = Company.find_by(siren: company["siren"].to_i)
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
    # input2.website = http(input2["siren"], cat)
    # input2.email = email(input2["siren"], cat)
    input2.save
  end

  # __________________________________

  def website(siren)
    apitoken = ENV['PAPPERS_API_KEY']
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

      domain_img2 = /(\/imgres\?imgurl=)(http)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_img = /(\/imgres\?imgurl=)(https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_linkedin = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_linke = /(\/url\?q=)(https)\:\/\/www\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_linkedines = /(\/url\?q=)(https)\:\/\/es\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
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
      domain_lesechos = /(\/url\?q=)(https)\:\/\/solutions\.lesech[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_athena = /(\/url\?q=)(http)\:\/\/athen[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_cndep = /(\/url\?q=)(https)\:\/\/cnde[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_df = /(\/url\?q=)(https)\:\/\/www\.detectives\-fra[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_isere = /(\/url\?q=)(https)\:\/\/www\.isere\.gou[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_french = /(\/url\?q=)(https)\:\/\/french\-lea[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_clau = /(\/url\?q=)(http)\:\/\/claudelicou[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_laval = /(\/url\?q=)(https)\:\/\/laval\.mavill[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_lavenirdelart = /(\/url\?q=)(http)\:\/\/www\.lavenirdelar[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_daily = /(\/url\?q=)(https)\:\/\/dailyno[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_tel = /(\/url\?q=)(https)\:\/\/www\.telepho[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_detami = /(\/url\?q=)(http)\:\/\/www\.detective\-amie[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_french2 = /(\/url\?q=)(https)\:\/\/french\-corpo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_d2 = /(\/url\?q=)(https)\:\/\/www\.omnirisinvestigation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_twit = /(\/url\?q=)(http)\:\/\/twitte[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto2 = /(\/url\?q=)(https)\:\/\/www\.mondoct[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto3 = /(\/url\?q=)(https)\:\/\/www\.cerg[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto4 = /(\/url\?q=)(http)\:\/\/www\.icfhabit[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_wiki = /(\/url\?q=)(https)\:\/\/fr\.wikipedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_wiki = /(\/url\?q=)(https)\:\/\/www\.spitpaslo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_dom = /(\/url\?q=)(https)\:\/\/www\.orpe[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/




      if url.match(domain_dom) || url.match(domain_img2) || url.match(domain_img) || url.match(domain_wiki) || url.match(domain_docto4) || url.match(domain_docto3) || url.match(domain_twit) || url.match(domain_d2) || url.match(domain_french2) || url.match(domain_detami) || url.match(domain_tel) || url.match(domain_daily) || url.match(domain_lavenirdelart) || url.match(domain_laval) || url.match(domain_clau) || url.match(domain_french) || url.match(domain_isere) || url.match(domain_linke) || url.match(domain_df) || url.match(domain_cndep) || url.match(domain_linkedines) || url.match(domain_athena) || url.match(domain_lesechos) || url.match(domain_dete) || url.match(domain_cnaps) || url.match(domain_rif) || url.match(domain_rci) || url.match(domain_erf) || url.match(domain_groupe) || url.match(domain_kompas) || url.match(domain_docto2) || url.match(domain_info) || url.match(domain_google2) || url.match(domain_mappy) || url.match(domain_facebook2) || url.match(domain_facebook) || url.match(domain_google) || url.match(domain_map) || url.match(domain_linkedin)
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
      p url
      return url
  end

  def email(siren, category)

    if http(siren, category).nil?
      p email_address = "N.C."
    else
      url = http(siren, category)
      p url

      if open(url).read == OpenURI::HTTPError || open(url).read.nil?
        p email_address = "N.C.2"
      else
        html_file = open(url).read
        if html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).nil?
          email_address = "N.C."
        else
          email_address = html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0].to_s
        end
      end
      return email_address
    end
  end

  def clearbit(email, website)
    if email == "N.C"
      url = URI("https://company.clearbit.com/v2/companies/find?domain=#{website}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = ENV['CLEARBIT_KEY']
      response = https.request(request)
      puts response.read_body

    else
      email = "N.C"
    end
    return email
  end
end

