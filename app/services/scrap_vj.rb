require "json"
require "open-uri"
require 'nokogiri'

class ScrapVj

  def get_vj_recruit_offers
    url_array = get_vj_url
    recruit_offers = get_recruit_offers_array(url_array)
    # p recruit_offers.first.class
    return recruit_offers
  end

  def get_vj_url
    url = 'https://www.village-justice.com/annonces/index.php?action=search&order_by=&ord=&6%5B%5D=103&6%5B%5D=104&multiselect=103&multiselect=104&14%5B%5D=98&14%5B%5D=191&multiselect=98&multiselect=191&5=&15=&8=&search='
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    links = html_doc.search('.table td a')
    url_recruit_offers = links.map{ |a| a.attribute("href").value }[6..-1]

    # href.each do |link|
    #   html_file2 = open(link).read
    #   html_doc2 = Nokogiri::HTML(html_file2)
    #   url_recruit_offers = []
    #   html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li').each do |element|
    #   url_recruit_offers << element.text.strip
    #   end
    # p url_recruit_offers
    return url_recruit_offers
  end

  def get_recruit_offers_array(url_array)
    # creer tableau vide pour stocker les recruit offers
    array_recruitment = []

    url_array.each do |url|
      # lire url
      html_file = open(url).read
      # transform en nokogiri
      html_doc = Nokogiri::HTML(html_file)
      recruit_offer = read_nokogiri_vj(html_doc)
      # ajouter les recruits offer dans le tableau <<
      array_recruitment << recruit_offer
    end
    return array_recruitment
  end

  def read_nokogiri_vj(nokogiri_objet)
  # recuperer les infos dans l'objet nokogiri et les stocker dans un hash
    recruit_offer = {}

    test1 = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(5) > i').text.strip
    if test1 == ""

    # ---- ANNONCE WITHOUT PICTURE ----
      post = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > h2').text.strip
      recruteur = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(2) > i').text.strip
      date = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(3) > i').text.strip
      city = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(4) > i').text.strip

    # ---- ANNONCE WITH PICTURE ----
    else
        post = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > h2').text.strip
        recruteur = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(3) > i').text.strip
        date = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(4) > i').text.strip
        city = nokogiri_objet.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(5) > i').text.strip

    end

    # effectuer assignation entre valeurs et cles symbol

    recruit_offer[:job_title] = post
    recruit_offer[:company_name] = recruteur
    recruit_offer[:publication_date] = date
    recruit_offer[:zip_code] = city
    recruit_offer[:external_id] = "4572455316479808419"
    recruit_offer[:category_id] = "Avocat"
    if recruit_offer[:company_name] == "TeamRH" || recruit_offer[:company_name] == "Neithwork" || recruit_offer[:company_name] == "Neithwork" || recruit_offer[:company_name] == "Fed Légal" || recruit_offer[:company_name] == "Michael Page" || recruit_offer[:company_name] == "Hays"
      recruit_offer[:siret] = "35081090900076"
      recruit_offer[:siren] = "350810909"
    else
      recruit_offer[:siret] = papers_name(recruteur)[0]
      recruit_offer[:siren] = papers_name(recruteur)[1]
    end
    #p recruit_offer.class
    return recruit_offer
  end

  def papers_name(company_name)
    url2 = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        code_naf: "69.10Z",
        entreprise_cessee: false,
        nom_entreprise: company_name.gsub(",", "")
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
    siret = result2["entreprises"][0]["siege"]["siret"]
    siren = result2["entreprises"][0]["siren"]
    return [siret, siren]
  end
end
