require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'

def website(siren)
  url = URI("https://api.pappers.fr/v1/entreprise?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&siren=#{siren}&entreprise_cessee=false")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
  response = https.request(request)
  return_array = response.read_body
  result = JSON.parse(return_array)
  # p result["nom_entreprise"]

  return result["nom_entreprise"]
end

def check_google(siren)
  query = website(siren)
  url = URI("https://www.google.com/search?q=#{query}&aqs=chrome..69i57j69i60j69i61.698j0j1&sourceid=chrome&ie=UTF-8")
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)
  links = html_doc.search('a')
  urls = links.map { |a| a.attribute("href").value }
  return urls
  # url_recruit_offers = links.map{ |a| a.attribute("href").value }
  # p links
end

def http(siren)
  array = []
  bin = []
  domain_regex = /(http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
  check_google(siren).each do |url|
    # p url
    if url.match(domain_regex)
      array << url
    else
      bin << url
    end
  end
  array.first(5)

  array2 = array.first(5)
  bin2 = []
  array3 = []

  array2.each do |url|
    # p url
    domain_map = /(https)\:\/\/maps[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_societe = /(\/url\?q=)(https)\:\/\/www\.soci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_pagesjaunes = /(\/url\?q=)(https)\:\/\/www\.pages[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_linkedin = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_mappy = /(\/url\?q=)(https)\:\/\/fr\.map[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    domain_consultation = /(\/url\?q=)(https)\:\/\/consultation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/


    # domain_docto = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_rdvmedi = /(\/url\?q=)(https)\:\/\/www.rdvmedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_docave = /(\/url\?q=)(https)\:\/\/www.docave[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_keldoc = /(\/url\?q=)(https)\:\/\/www.keldo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    if url.match(domain_map) || url.match(domain_societe) || url.match(domain_pagesjaunes) || url.match(domain_linkedin) || url.match(domain_consultation) || url.match(domain_doctrine)
      bin2 << url
    else
      array3 << url
    end
  end

  p array3

  return array3
end

http(518967096)
# result
