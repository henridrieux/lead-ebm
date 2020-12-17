require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'

class Google

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

      # URL AVOCAT

      domain_consultation = /(\/url\?q=)(https)\:\/\/consultation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_annuaireacte = /(\/url\?q=)(http)\:\/\/annuaire[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL NOTAIRE

      # domain_notaire = /(\/url\?q=)(https)\:\/\/www\.notair[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      # URL MEDECIN

      domain_docto = /(\/url\?q=)(http)\:\/\/doctoli[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docto2 = /(\/url\?q=)(https)\:\/\/www\.docto[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_rdvmedi = /(\/url\?q=)(https)\:\/\/www.rdvmedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_docave = /(\/url\?q=)(https)\:\/\/www.docave[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_keldoc = /(\/url\?q=)(https)\:\/\/www.keldo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
      domain_lemedecin = /(\/url\?q=)(https)\:\/\/lemedeci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

      if url.match(domain_lemedecin) || url.match(domain_docto2) || url.match(domain_docto) || url.match(domain_rdvmedi) || url.match(domain_docave) || url.match(domain_keldoc) || url.match(domain_facebook2) || url.match(domain_facebook) || url.match(domain_annuaireacte) || url.match(domain_google) || url.match(domain_map) || url.match(domain_societe) || url.match(domain_pagesjaunes) || url.match(domain_linkedin) || url.match(domain_consultation) || url.match(domain_doctrine)
        bin2 << url
      else
        array3 << url
      end
    end

    p array3

    clean = array3.first.to_s.delete_prefix('/url?q=').split('&')
    clean1 = clean.first

    p clean1

    return clean1
  end

  def email(siren, category)
    url = http(siren, category)
    # p url
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    links = html_doc.search('body')
    # domain_regex = (/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    content = links.to_s
    #p content
    if content.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).nil?
      email_address = 'pas d email'
    else
      email_address = content.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
    end

    p email_address
  end

  def check_category_greffier(siren)
    query = website(siren)
    url = URI("https://www.google.com/search?q=#{query}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
    html_file = open(url).read

    if html_file.match?(/[a-zA-Z0-9\-\.]dministrateu[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]ommissair[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]uissie[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]otaire[a-zA-Z0-9\-\.](\/\S*)?/i).nil? || html_file.match?(/[a-zA-Z0-9\-\.]voca[a-zA-Z0-9\-\.](\/\S*)?/i).nil?
      cat = "Greffier"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]dministrateu[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Administrateur judiciaire"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]ommissair[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Commissaire-priseur"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]uissie[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Huissier"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]otaire[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Notaire"
    elsif html_file.match?(/[a-zA-Z0-9\-\.]voca[a-zA-Z0-9\-\.](\/\S*)?/i)
      cat = "Avocat"
    end

    return cat
  end

  # check_category(844812545)

  # SIREN ADM JURIDICAIRE

  siren1 = 423606326

  # SIREN AVOCAT

  siren = 342119047
  siren1 = 434963922
  siren2 = 880609227
  siren3 = 880612056
  siren4 = 880611983
  siren5 = 844757161

  # SIREN NOTAIRE

  siren = 390949840
  siren1 = 813555885
  siren2 = 337936322
  siren3 = 831526967

  # SIREN MEDECIN

  siren = 340657667
  siren1 = 348597485
  siren2 = 330625203

  #email(844768028, "avocat")
  # http(siren2, 'medecin')
  # email(siren5, 'Avocat')
end
