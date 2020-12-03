require "json"
require "open-uri"
require 'nokogiri'

class ScrapVj

  url = 'https://www.village-justice.com/annonces/index.php?action=search&order_by=&ord=&6%5B%5D=103&6%5B%5D=104&multiselect=103&multiselect=104&search='
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)

  links = html_doc.search('.table td a')
  href = links.map{ |a| a.attribute("href").value }[6..-1]

  href.each do |link|
    html_file2 = open(link).read
    html_doc2 = Nokogiri::HTML(html_file2)
    data = []
    html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li').each do |element|
    # puts element.text.strip
    data << element.text.strip
    end
    #p data
  end

  href.each do |link|
  html_file2 = open(link).read
  html_doc2 = Nokogiri::HTML(html_file2)
  test1 = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(5) > i').text.strip
    if test1 == ""

  # ---- ANNONCE WITHOUT PICTURE ----

    post = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > h2').text.strip
    recruteur = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(2) > i').text.strip
    data = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(3) > i').text.strip
    city = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(4) > i').text.strip

  # ---- ANNONCE WITH PICTURE ----
  else

      post = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > h2').text.strip
      recruteur = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(3) > i').text.strip
      date = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(4) > i').text.strip
      city = html_doc2.search('#main > div > div.col-xs-12.col-sm-7.col-md-7.col-lg-7 > span > ul > li:nth-child(5) > i').text.strip

    p recruteur

    end
  end
end


