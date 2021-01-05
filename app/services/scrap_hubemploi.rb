require "json"
require "open-uri"
require 'nokogiri'
require 'openssl'

class ScrapHubemploi

  def create_hubemploi_recruitment
    @nb_update = 0
    @nb_create = 0
    get_vj_recruit_offers.each do |recruit_offer|
      # p recruit_offer[:siret]
      if Recruitment.find_by(external_id: recruit_offer[:external_id])
        p "emploi updated"
        @nb_update +=1
      else
        create_company(recruit_offer)
        create_recruitment(recruit_offer)
        p "emploi created"
        company = Company.find_by(siret: recruit_offer[:siret])
        # p company
        company.category_id = 17
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
    url = 'https://www.hubemploi.fr/candidate-search-offer?candidate_offer_filter%5Blieu%5D=&candidate_offer_filter%5Bbounding_box%5D=&candidate_offer_filter%5Bcontract_type_ids%5D%5B%5D=1&candidate_offer_filter%5Bcontract_type_ids%5D%5B%5D=2&candidate_offer_filter%5Bdistance_range%5D=10&candidate_offer_filter%5Bdistance%5D=10&candidate_offer_filter%5Bsalary_min%5D=20000&candidate_offer_filter%5Bsort%5D=date%7Cdesc&candidate_offer_filter%5Blimit%5D=10&candidate_offer_filter%5Boffset%5D=0'
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    links = html_doc.search("a")
    url_website = links.map { |a| "https://www.hubemploi.fr" + a.attribute("href").value }
    bin = []
    url_recruit_offers = []
    url_website.each do |link|
      #p link
      if link.match(/(https)\:\/\/www\.hubemploi\.fr\/offer-detai[a-zA-Z0-9\-\.](\/\S*)?/)
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
    return array_recruitment
  end

  def read_nokogiri_vj(nokogiri_objet)
  # recuperer les infos dans l'objet nokogiri et les stocker dans un hash
    recruit_offer = {}

    post = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.bg-white > div > div > div > div.w-full > h1').text.strip
    recruteur = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.bg-white > div > div > div > div.flex.flex-col.md\:flex-row > div > p.text-24.font-bold.uppercase').text.strip
    date = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.bg-white > div > div > div > div.published-date').text.strip
    city = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.bg-white > div > div > div > div.flex.flex-col.md\:flex-row > div > p.font-bold.text-base.mt-2').text.strip
    contrat = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.flex.flex-col-reverse.lg\:flex-row.pb-24.px-2.lg\:px-0.w-4\/5.lg\:w-full.mx-auto.z-10 > div.w-full.lg\:w-9\/10 > div:nth-child(1) > div > div:nth-child(1) > p').text.strip
    job_desc = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.flex.flex-col-reverse.lg\:flex-row.pb-24.px-2.lg\:px-0.w-4\/5.lg\:w-full.mx-auto.z-10 > div.w-full.lg\:w-9\/10 > div.bg-white.my-4.py-8.md\:pt-12.md\:pb-16.px-6.sm\:px-8.md\:px-12.lg\:px-16.xl\:px-20.xxl\:px-24.w-full > div:nth-child(1) > div.paragraph.wysiwyg.wysiwyg--candidate > p').text.strip
    external_id = nokogiri_objet.search('#app > div.app-body.leading-loose.text-base.md\:text-lg > div.bg-grey-lightest.w-full > div > div.slice_wrapper.bg-grey-lightest.candidate-color > div > div > div > div.flex.flex-col-reverse.lg\:flex-row.pb-24.px-2.lg\:px-0.w-4\/5.lg\:w-full.mx-auto.z-10 > div.w-full.lg\:w-9\/10 > div.bg-white.my-4.py-8.md\:pt-12.md\:pb-16.px-6.sm\:px-8.md\:px-12.lg\:px-16.xl\:px-20.xxl\:px-24.w-full > div.w-full.paragraph > span').text.strip
    # effectuer assignation entre valeurs et cles symbol

    recruit_offer[:job_title] = post
    recruit_offer[:company_name] = recruteur
    recruit_offer[:publication_date] = date
    recruit_offer[:zip_code] = city
    #.split(/(?<=\d)(?=[A-Za-z])/).first
    # recruit_offer[:publication_date] = Date.today
    recruit_offer[:contract_type] = contrat
    recruit_offer[:job_description] = job_desc
    recruit_offer[:external_id] = external_id

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
      publication_date: Date.today,
      # employer_email: recruitoffer["mail"],
      job_description: recruit_offer[:job_description],
      # employer_name: recruitoffer["label"],
      # employer_phone: recruitoffer["phone"],
      external_id: recruit_offer[:external_id]
    )
    #p 'la'
    input.company = create_company(recruit_offer)
    input.company.category_id = 12
    input.save
    # p "ici"
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
