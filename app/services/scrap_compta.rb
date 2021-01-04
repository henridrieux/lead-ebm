require "json"
require "open-uri"
require 'nokogiri'

class ScrapCompta

  def create_comptajob_recruitment
    get_vj_recruit_offers.each do |recruit_offer|
      # p recruit_offer[:siret]
      if recruit_offer[:siret] == "N.C"
        p "cabinet de recrutment"
      else
        create_company(recruit_offer)
        create_recruitment(recruit_offer)
        p 'Création 1 entreprise'
        company = Company.find_by(siret: recruit_offer[:siret])
        p company
        company.category_id = 17
        company.save
        p company.category_id
      end
    end
  end

  def get_vj_recruit_offers
    url_array = get_vj_url
    recruit_offers = get_recruit_offers_array(url_array)
    return recruit_offers
  end

  def get_vj_url
    url = 'https://www.comptajob.fr/'
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    #p html_doc

    links = html_doc.search('td a')
    #p links
    url_recruit_offers = links.map{ |a| "https://www.comptajob.fr/" + a.attribute("href").value }
    #p url_recruit_offers
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
    p array_recruitment
    return array_recruitment
  end

  def read_nokogiri_vj(nokogiri_objet)
  # recuperer les infos dans l'objet nokogiri et les stocker dans un hash
    recruit_offer = {}

    post = nokogiri_objet.search('body > main > section > div:nth-child(3) > div > div.col-sm-8 > p:nth-child(2) > strong').text.strip
    recruteur = nokogiri_objet.search('body > main > section > div:nth-child(3) > div > div.col-sm-4 > p').text.strip
    date = nokogiri_objet.search('body > main > section > div:nth-child(3) > div > div.col-sm-8 > p.pull-right').text.strip
    city = nokogiri_objet.search('body > main > section > div:nth-child(3) > div > div.col-sm-8 > strong > strong > p:nth-child(3) > strong').text.strip
    contrat = nokogiri_objet.search('body > main > section > div:nth-child(3) > div > div.col-sm-8 > p:nth-child(3) > strong').text.strip
    job_desc = nokogiri_objet.search('body > main > section > strong > strong > div').text.strip

    # effectuer assignation entre valeurs et cles symbol

    recruit_offer[:job_title] = post
    recruit_offer[:company_name] = recruteur
    recruit_offer[:publication_date] = date
    recruit_offer[:zip_code] = city
    #.split(/(?<=\d)(?=[A-Za-z])/).first
    # recruit_offer[:publication_date] = Date.today
    recruit_offer[:contract_type] = contrat
    recruit_offer[:job_description] = job_desc

    # if recruit_offer[:company_name] == "Teamrh" || recruit_offer[:company_name] == "Fidal" || recruit_offer[:company_name] == "Lamartine Conseil" || recruit_offer[:company_name] == "Fed Legal" || recruit_offer[:company_name] == "Hermexis Avocats Associés" || recruit_offer[:company_name] == "Legal&HR Talents" || recruit_offer[:company_name] == "Neithwork" || recruit_offer[:company_name] == "Fed Légal" || recruit_offer[:company_name] == "Michael Page" || recruit_offer[:company_name] == "Hays"
    #   recruit_offer[:siret] = "N.C"
    #   recruit_offer[:siren] = "N.C"
    #   #p "cabinet de recrutment"
    # else
    #   #p recruteur
    recruit_offer[:siret] = papers_name(recruteur)[0]
      # p recruit_offer[:siret]
    recruit_offer[:siren] = papers_name(recruteur)[1]
    # end
    return recruit_offer
  end

  def create_recruitment(recruit_offer)
    @nb_create = 0

    input = Recruitment.new(
      zip_code: recruit_offer[:zip_code].to_i,
      employer: recruit_offer[:company_name],
      job_title: recruit_offer[:job_title],
      # category_id: recruit_offer[:category_id]
      contract_type: recruit_offer[:contract_type],
      publication_date: recruit_offer[:publication_date],
      # employer_email: recruitoffer["mail"],
      job_description: recruit_offer[:job_description]
      # employer_name: recruitoffer["label"],
      # employer_phone: recruitoffer["phone"],
      # external_id: recruitoffer["idOffer"]
    )
    input.company = create_company(recruit_offer)
    input.company.category_id = 17
    input.save
    # if input.save
    #   @nb_create += 1
    # end
  end

  def papers_name(company_name)
    company_name1 = company_name.parameterize
    #p company_name1
    url = URI("https://api.pappers.fr/v1recherche?nom_entreprise=#{company_name1}&code_naf=69.20Z&api_token=c8c26742dc2e31f8ad0059a0d4069c4c66addf1cdddfea7a&par_page=1&entreprice_cessee=false")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
    response = https.request(request)
    company = JSON.parse(response.read_body)

    if  company["entreprises"].blank?
      siret = 'N.C'
      siren = 'N.C'
    else
      siret = company["entreprises"][0]["siege"]["siret"]
      siren = company["entreprises"][0]["siren"]
    end
    #p siren
    return [siret, siren]
  end

  def create_company(recruit_offer)
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
        naf_code: "69.20Z",
        zip_code: recruit_offer[:zip_code],
        city: recruit_offer[:city],
        category_id: Category.find_by(name: "Comptable").id
      )
      # enrichissement de la company
      APIPapers.new.papers_one((new_company.siret).to_i)
    end
  end
end

#ScrapComptaJob.new.create_comptajob_recruitment
