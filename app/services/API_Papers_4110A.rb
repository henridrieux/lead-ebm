# # _________ PROMOTION IMMO ___________

require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'
require 'clearbit'
require "uri"
require 'httparty'
require "net/http"

class APIPapers4110a
# Or wrap things up in your own class

  def papers_all(number, date_string, date_end_string)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: ENV['PAPPERS_API_KEY'],
        par_page: number,
        entreprise_cessee: false,
        code_naf: "41.10A",
        date_creation_min: date_string,
        date_creation_max: date_end_string,
        departement: 75,
        tranche_effectif_min: 4
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
    # puts "#{@nb_create} création et #{@nb_update} update"
    Company.find_by(siret: siret.to_i)
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
    # p result2
    return result2
  end

  def check_company(company)
    if company["siren"].nil?
      p 'error'
    elsif Company.find_by(siren: company["siren"].to_i)
      #update_company_adress(company)
      #update_company_siret_counter(company)
      #check_company_manager_name(company)
      # check_company_website(company)
      @nb_update += 1
    elsif company["siren"].nil?
      p 'no company'
    else
      create_company(company)
      @nb_create += 1
      sleep 1.5
    end
    # sleep 2
  end

  def headquarter_count(siren)
    apitoken = ENV['PAPPERS_API_KEY'],
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=#{apitoken}&siren=#{siren}&entreprise_cessee=false")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)

    if result["etablissements"].nil?
      result = 1
    else
      result = result["etablissements"].count
    end
    return result
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

    cat = "promotion immobiliere"
    input2.category = Category.find_by(name: cat)
    input2.website = http(input2["siren"], cat)
    input2.email = email(input2["siren"], cat)
    input2.save
  end

  def update_company(company)
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
    cat = "promotion immobiliere"
    input2.category = Category.find_by(name: cat)
    input2.save
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
      address: company["siege"]["adresse_ligne_1"],
      zip_code: company["siege"]["code_postal"],
      city: company["siege"]["ville"],
      last_moving_date: last_moving_date,
    )
    input2.save
  end

  def update_company_siret_counter(company)
    input2 = Company.find_by(siren: company["siren"].to_i)
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
    input2 = Company.find_by(siren: company["siren"].to_i)
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
    input2 = Company.find_by(siren: company["siren"].to_i)
    website_old = input2[:website]
    cat = "promotion immobiliere"
    # input2.category = Category.find_by(name: cat)
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
    apitoken = ENV['PAPPERS_API_KEY']
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=#{apitoken}&siren=#{siren}&entreprise_cessee=false")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)

    if result["nom_entreprise"].nil? || result["siege"].nil? || result["siege"]["ville"].nil?
      result = "entreprise"
    else
      result = result["nom_entreprise"] + " " + result["siege"]["ville"].parameterize
    end
    return result
  end

  def check_google(siren, category)
    query = website(siren)
    if query == "\"statusCode\"=>400, \"error\"=>\"Requ\u00EAte mal format\u00E9e\", \"message\"=>\"Veuillez indiquer un num\u00E9ro SIREN ou SIRET valide\""
      query = "entreprise"
    else
      query = website(siren)
    end
    cat = category
    url = URI("https://www.google.com/search?q=#{query} #{cat}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
    #p url
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

    array2 = array.first(5)
    bin2 = []
    array3 = []
    array2.each do |url|
      # URL GOOGLE

      domain_map = /(https)\:\/\/maps[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_google = /(https)\:\/\/www\.googl[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL CLASSIQUE

      domain_1 = /(\/url\?q=)(https)\:\/\/www\.soci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_2 = /(\/url\?q=)(https)\:\/\/www\.pages[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_3 = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_4 = /(\/url\?q=)(https)\:\/\/fr\.map[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_5 = /(\/url\?q=)(https)\:\/\/fr-fr\.faceboo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_6 = /(\/url\?q=)(https)\:\/\/www\.face[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_7 = /(\/url\?q=)(https)\:\/\/www\.veri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_8 = /(\/url\?q=)(http)\:\/\/entreprises\.lefiga[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_9 = /(\/url\?q=)(https)\:\/\/www\.infogre[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_10 = /(\/url\?q=)(https)\:\/\/www\.sirensire[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_11 = /(\/url\?q=)(https)\:\/\/solution[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/


      if url.match(domain_map) || url.match(domain_google) || url.match(domain_1) || url.match(domain_2) || url.match(domain_3) || url.match(domain_4) || url.match(domain_5) || url.match(domain_6) || url.match(domain_7) || url.match(domain_8) || url.match(domain_9) || url.match(domain_10) || url.match(domain_11)
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
      email_address = "N.C."
    else
      email_address = check_url_validity(siren, category)
      return email_address
    end
  end

  def check_url_validity(siren, category)
    url = http(siren, category)
    html_file = open(url).read
    email_address = check_email_adress(html_file)

    # url = URI.parse("#{url}")
    # req = Net::HTTP.new(url.host, url.port)
    # res = req.request_head(url.path)

    # if res
    #   html_file = open(url).read
    #   email_address = check_email_adress(html_file)
    # else
    #   email_address = "N.C."
    # end

    return email_address
  end

  def check_email_adress(html_file)
    if html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).nil?
      email_address = "N.C."
    else
      email_address = html_file.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0].to_s
    end
    #p email_address
    return email_address
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


end

# APIPapers6920Z.new.papers_all(20, "01-01-2020")
