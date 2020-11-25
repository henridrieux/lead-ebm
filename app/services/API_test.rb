# class APIBourseEmploi
# # Or wrap things up in your own class
# require "json"
# require "open-uri"
# require "net/http"


#     url = URI("https://bourse-emplois.notaires.fr/api/offre/search?page=1&pageSize=90&sort=DESC&sortField=DATE_ACTUALISATION")

#     https = Net::HTTP.new(url.host, url.port)
#     https.use_ssl = true

#     request = Net::HTTP::Post.new(url)
#     request["Pragma"] = "no-cache"
#     request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36"
#     request["Content-Type"] = "application/json"
#     request["Accept"] = "*/*"
#     request["Cookie"] = "_ga=GA1.3.1335572239.1606137983; _gid=GA1.3.89168093.1606137983; tartaucitron=!analytics=true!recaptcha=true; Cookie_1=value"
#     request.body = "{\"cityFilter\":[],\"departmentFilter\":[],\"functionFilter\":[],\"geolocalisationFilter\":{},\"hasNextPage\":false,\"otherFilter\":{\"workingTime\":[],\"type\":[],\"professionalFormation\":[],\"availability\":[],\"keyWord\":\"\"},\"pageNumber\":1,\"pageSize\":90,\"regionFilter\":[],\"resultCount\":0,\"sortMethod\":\"DESC\",\"launchSearch\":false,\"sortField\":\"DATE_ACTUALISATION\"}"

#     response = https.request(request)
#      return_array = response.read_body

#     result = JSON.parse(return_array)
#      new_id_array = []
#     result["content"].each do |v|
#       new_id_array << v["id"]
#     end

#     puts new_id_array
#     # @new_id_array.each do |item|
#     # puts item["id"]



#     # puts "https://bourse-emplois.notaires.fr/api/offre/preview/#{id}"
#     # end

# end

