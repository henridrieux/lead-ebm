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
  # url_recruit_offers = links.map{ |a| a.attribute("href").value }
  # p links
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
  #p array.first(6)

  array2 = array.first(6)
  bin2 = []
  array3 = []

  array2.each do |url|
    # p url

    # URL GOOGLE

    domain_map = /(https)\:\/\/maps[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_google = /(https)\:\/\/www\.googl[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    # URL CLASSIQUE

    domain_societe = /(\/url\?q=)(https)\:\/\/www\.soci[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_pagesjaunes = /(\/url\?q=)(https)\:\/\/www\.pages[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_linkedin = /(\/url\?q=)(https)\:\/\/fr\.linked[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_mappy = /(\/url\?q=)(https)\:\/\/fr\.map[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    # URL AVOCAT

    domain_consultation = /(\/url\?q=)(https)\:\/\/consultation[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    domain_annuaireacte = /(\/url\?q=)(http)\:\/\/annuaire[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    # URL MEDECIN

    # domain_docto = /(\/url\?q=)(https)\:\/\/www\.docto[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_rdvmedi = /(\/url\?q=)(https)\:\/\/www.rdvmedi[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_docave = /(\/url\?q=)(https)\:\/\/www.docave[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
    # domain_keldoc = /(\/url\?q=)(https)\:\/\/www.keldo[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/

    if url.match(domain_annuaireacte) ||url.match(domain_google) || url.match(domain_map) || url.match(domain_societe) || url.match(domain_pagesjaunes) || url.match(domain_linkedin) || url.match(domain_consultation) || url.match(domain_doctrine)
      bin2 << url
    else
      array3 << url
    end
  end

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
  if content.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0].nil?
    p 'pas d email'
  else
    email_address = content.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
  end

  p email_address
end

# siren = 342119047
# siren1 = 434963922
#siren2 = (880609227, 'avocat')
# siren = 880612056
# siren = 880611983
# siren = 880667530
# siren = 880556691

http(434963922, 'avocat')
email(434963922, 'avocat')

# def email(siren)
#   query = website(siren)
#   cat = "avocat"
#   url = URI("https://www.google.com/search?q=#{query} #{cat}&aqs=chrome..69i57j33i160.30487j0j7&sourceid=chrome&ie=UTF-8")
#   # p url
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   text = html_doc.search('#search')
#   domain_regex = (/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
#   text.each do |span|
#     p span
#   end
#   # if text.match(domain_regex)
#   #   p text
#   # end
#   # span = text.map { |a| a.attribute("span").value }
#   # p span

#   return
# end

# email(440821197)

# def doctrine(siren)
#   array = []
#   bin = []
#   domain_regex = /(http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
#   check_google(siren).each do |url|
#     # p url
#     if url.match(domain_regex)
#       array << url
#     else
#       bin << url
#     end
#   end
#   # p array.first(6)
#   array2 = array.first(6)
#   bin2 = []
#   array3 = []
#   array2.each do |url|
#     # p url
#     domain_doctrine = /(\/url\?q=)(https)\:\/\/www\.doctri[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/
#     if url.match(domain_doctrine)
#       bin2 << url
#     else
#       array3 << url
#     end
#   end
#   # p bin2
#   return bin2
# end

# def website_doctrine(siren)
#   urldoctrine = doctrine(siren).first.to_s.delete_prefix('/url?q=')[0...-88]
#   # p urldoctrine
#   url = URI(urldoctrine)
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   links = html_doc.search('#professional-about')
#   p links
#   urls = links.map { |a| a.attribute("href").value }
#   p urls
#   return urls
# end


# result
