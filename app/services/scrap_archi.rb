require "json"
require "open-uri"
require 'nokogiri'
require 'openssl'

class ScrapArchi

  def create_archi_recruitment
    @nb_update = 0
    @nb_create = 0
    get_vj_recruit_offers.each do |recruit_offer|
      if Recruitment.find_by(job_title: recruit_offer[:job_title]) && Recruitment.find_by(employer: recruit_offer[:company_name])
        p "emploi updated"
        @nb_update +=1
      else
        create_company(recruit_offer)
        create_recruitment(recruit_offer)
        p "emploi created"
        company = Company.find_by(siren: recruit_offer[:siren])
        company.category_id = 9
        company.save
        @nb_create+=1
      end
    end
    puts "#{@nb_create} créations et #{@nb_update} updates"
  end

  def get_vj_recruit_offers
    url_array = get_vj_url
    recruit_offers = get_recruit_offers_array(url_array)
    return recruit_offers
  end

  def get_vj_url
    url = 'https://www.architectes.org/recherche-annonce/type-annonce/offre-d-emploi-cdi-6/type-annonce/offre-d-emploi-cdd-5?text='
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    links = html_doc.search("a")
    url_website = links.map { |a| "https://www.architectes.org" + a.attribute("href").to_s }
    bin = []
    url_recruit_offers = []
    url_website.each do |link|
      #p link
      if link.match(/(https)\:\/\/www\.architectes\.org\/(petites-annonce)[a-zA-Z0-9\-\.](\/\S*)?/)
        url_recruit_offers << link
      else
        bin << link
      end
    end
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
    #p array_recruitment
    return array_recruitment
  end

  def read_nokogiri_vj(nokogiri_objet)
  # recuperer les infos dans l'objet nokogiri et les stocker dans un hash
    recruit_offer = {}

    post = nokogiri_objet.search('div > div.central > div.field.field-name-title-field.field-type-text.field-label-hidden > div > div > h1').text.strip
    recruteur = nokogiri_objet.search('div > div.aside > div.info-contact > table > tbody > tr:nth-child(1) > td:nth-child(2)').text.strip
    date = nokogiri_objet.search('div > div.central > div.dates').text.strip
    date = date.match(/\d{2}.\d{2}.\d{4}/).to_s
    #p date
    city = nokogiri_objet.search('div > div.aside > div.info-contact > table > tbody > tr:nth-child(2) > td:nth-child(2) > span.zip').text.strip
    # city = city.split(/(?<=\d)(?=[A-Za-z])/)
    # p city
    contrat = nokogiri_objet.search('div > div.central > div.field.field-name-field-annonce-type.field-type-taxonomy-term-reference.field-label-hidden > div > div > div > div > a').text.strip
    job_desc = nokogiri_objet.search('div > div.central > div.field.field-name-body.field-type-text-with-summary.field-label-hidden > div > div > p:nth-child(1)').text.strip
    # external_id = nokogiri_objet.search('').text.strip
    employer_email = nokogiri_objet.search('div > div.aside > div.info-contact > table > tbody > tr:nth-child(5) > td:nth-child(2) > a').text.strip

    # effectuer assignation entre valeurs et cles symbol

    recruit_offer[:job_title] = post
    recruit_offer[:company_name] = recruteur
    recruit_offer[:publication_date] = date
    recruit_offer[:zip_code] = city
    #.split(/(?<=\d)(?=[A-Za-z])/).first
    # recruit_offer[:publication_date] = Date.today
    recruit_offer[:contract_type] = contrat
    recruit_offer[:job_description] = job_desc
    #recruit_offer[:external_id] = external_id
    recruit_offer[:mail] = employer_email

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
    #nb_external_id = 0

    input = Recruitment.new(
      zip_code: recruit_offer[:zip_code].to_i,
      employer: recruit_offer[:company_name],
      job_title: recruit_offer[:job_title],
      # category_id: recruit_offer[:category_id]
      contract_type: recruit_offer[:contract_type],
      publication_date: recruit_offer[:publication_date],
      employer_email: recruit_offer[:mail],
      job_description: recruit_offer[:job_description],
      # employer_name: recruitoffer["label"],
      # employer_phone: recruitoffer["phone"],
      external_id: recruit_offer[:external_id]
    )

    # nb_external_id +=1
    # input.external_id = nb_external_id
    input.company = create_company(recruit_offer)
    input.company.category_id = 9
    input.save
    # p "ici"
    if input.save
      @nb_create += 1
    end
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
        naf_code: "71.11Z",
        zip_code: recruit_offer[:zip_code],
        city: recruit_offer[:city],
        category_id: Category.find_by(name: "Architecte").id
      )
      # enrichissement de la company
      APIPapers.new.papers_one((new_company.siret).to_i)
    end
  end
end
