require "json"
require "open-uri"
require 'nokogiri'

class ScrapVj

  def get_vj_recruit_offers
    url_array = get_vj_url
    recruit_offers = get_recruit_offers_array(url_array)
    p recruit_offers
    return recruit_offers
  end

  def get_vj_url
    url = 'https://www.village-justice.com/annonces/index.php?action=search&order_by=&ord=&6%5B%5D=103&6%5B%5D=104&multiselect=103&multiselect=104&search='
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
    p array_recruitment
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

    # effectuer assignation ezntre valeurs et cles symbol
    recruit_offer[:job_title] = post
    recruit_offer[:employer] = recruteur
    recruit_offer[:publication_date] = date
    recruit_offer[:zip_code] = city

    #p recruit_offer
    return recruit_offer
  end
end


