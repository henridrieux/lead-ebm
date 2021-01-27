# require "json"
# require "open-uri"
# require 'nokogiri'

# ______ EMAIL _____

# def scrap(numP)
#   page = numP
#   url = "https://commissaires-priseurs.org/annuaire/?cn-cat=#{page}"
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   #p html_doc
#   links = html_doc.search('a')
#   #p links
#   url_recruit_offers = links.map{ |a| a.attribute("href").value }
#   #p url_recruit_offers
#   # return url_recruit_offers
#   email_adress = []
#   url_recruit_offers.each do |email|
#     if email.match(/(mailto)\:[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
#       email_adress << email.split(":")[1]
#     end
#   end
#   p numP
#   return email_adress
# end

# total_email = []
# num = (51..94)
# num.each do |x|
#   total_email << scrap(x)
# end

# #p total_email

# total_email.each do |page|
#   page.each do |email|
#     p email
#   end
# end

# ________ NOM ________

# def scrap(numP)
#   page = numP
#   url = "https://commissaires-priseurs.org/annuaire/pg/#{page}/?cn-s&cn-cat=0"
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   #p html_doc
#   links = html_doc.search('h3')
#   #p links
#   url_recruit_offers = links.map{ |a| a.text.strip }
#   #p url_recruit_offers
#   # return url_recruit_offers
#   name = []
#   name << url_recruit_offers
#   p numP
#   return name
# end

# total_name = []
# num = (1..20)
# num.each do |x|
#   total_name << scrap(x)
# end

# total_name.each do |page|
#   page.each do |name|
#     name.each do |a|
#       p a
#     end
#   end
# end

# # ________ Adresse ________

# def scrap(numP)
#   page = numP
#   url = "https://commissaires-priseurs.org/annuaire/pg/#{page}/?cn-s&cn-cat=0"
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   #p html_doc
#   links = html_doc.search('span.address-block > span')
#   #p links
#   url_recruit_offers = links.map{ |a| a.text.strip }
#   #p url_recruit_offers
#   # return url_recruit_offers
#   name = []
#   name << url_recruit_offers
#   p numP
#   return name
# end

# total_name = []
# num = (1..20)
# num.each do |x|
#   total_name << scrap(x)
# end

# total_name.each do |page|
#   page.each do |name|
#     name.each do |a|
#       p a
#     end
#   end
# end

#________ num ________

# def scrap(numP)
#   page = numP
#   url = "https://commissaires-priseurs.org/annuaire/pg/#{page}/?cn-s&cn-cat=0"
#   html_file = open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   #p html_doc
#   links = html_doc.search('span.phone-number-block > span:nth-child(1) > span.value')
#   #p links
#   url_recruit_offers = links.map{ |a| a.text.strip }
#   #p url_recruit_offers
#   # return url_recruit_offers
#   num = []
#   num << url_recruit_offers
#   p numP
#   return num
# end

# total_name = []
# num = (1..20)
# num.each do |x|
#   total_name << scrap(x)
# end

# total_name.each do |page|
#   page.each do |name|
#     name.each do |a|
#       p a
#     end
#   end
# end

