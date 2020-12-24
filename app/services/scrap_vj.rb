require "json"
require "open-uri"
require 'nokogiri'

class ScrapVj

  def create_vj_recruitment
    get_vj_recruit_offers.each do |recruit_offer|
      # p recruit_offer[:siret]
      if recruit_offer[:siret] == "N.C"
        p "cabinet de recrutment"
      else
        create_company(recruit_offer)
        create_recruitment(recruit_offer)
        p 'Création 1 entreprise'
      end

    end
  end

  def get_vj_recruit_offers
    url_array = get_vj_url
    recruit_offers = get_recruit_offers_array(url_array)
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
    # recruit_offer[:external_id] = "4572455316479808419"
    # recruit_offer[:category_id] = 1
    if recruit_offer[:company_name] == "Teamrh"  || recruit_offer[:company_name] == "Hermexis Avocats Associés" || recruit_offer[:company_name] == "Legal&HR Talents" || recruit_offer[:company_name] == "Neithwork" || recruit_offer[:company_name] == "Fed Légal" || recruit_offer[:company_name] == "Michael Page" || recruit_offer[:company_name] == "Hays"
      recruit_offer[:siret] = "N.C"
      recruit_offer[:siren] = "N.C"
      #p "cabinet de recrutment"
    else
      #p recruteur
      recruit_offer[:siret] = papers_name(recruteur)[0]
      # p recruit_offer[:siret]
      recruit_offer[:siren] = papers_name(recruteur)[1]
    end
    #p recruit_offer.class
    return recruit_offer
  end

  def create_recruitment(recruit_offer)
    @nb_create = 0

    input = Recruitment.new(
      zip_code: recruit_offer[:zip_code].to_i,
      employer: recruit_offer[:company_name],
      job_title: recruit_offer[:job_title],
      # category_id: recruit_offer[:category_id]
      # contract_type: recruitoffer["contractType"],
      # publication_date: recruitoffer["datePublication"],
      # employer_email: recruitoffer["mail"],
      # job_description: recruitoffer["description"],
      # employer_name: recruitoffer["label"],
      # employer_phone: recruitoffer["phone"],
      # external_id: recruitoffer["idOffer"]
    )
    #p 'la'
    input.company = create_company(recruit_offer)
    input.company.category_id = 1
    p input.company.category_id
    if input.save
      @nb_create += 1
    end
  end

  def papers_name(company_name)
    #p company_name
    url = URI("https://api.pappers.fr/v1recherche?nom_entreprise=#{company_name}&code_naf=69.10Z&api_token=c8c26742dc2e31f8ad0059a0d4069c4c66addf1cdddfea7a&par_page=1&entreprice_cessee=false")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    company = JSON.parse(response.read_body)
    siret = company["entreprises"][0]["siege"]["siret"]
    siren = company["entreprises"][0]["siren"]
    return [siret, siren]
  end

  def create_company(recruit_offer)
    # p 'hello'
    # p recruit_offer.class
    # p recruit_offer[:company_name]
    # p recruit_offer[:siren]

    company = Company.find_by(siren: recruit_offer[:siren])
    # p company
    if company
      company
      # p 'deja en place'
    else
      p "en création"
      # creation rapide de la company
      new_company = Company.create!(
        company_name: recruit_offer[:company_name],
        siret: recruit_offer[:siret],
        siren: recruit_offer[:siren],
        naf_code: "69.10Z",
        zip_code: recruit_offer[:zip_code],
        city: recruit_offer[:city],
        category_id: Category.find_by(name: "Avocat").id
      )
      # enrichissement de la company
      APIPapers.new.papers_one((new_company.siret).to_i)
      # p new_company.category_id
      # new_company.save
    end
  end
end

