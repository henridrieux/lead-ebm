require 'rest-client'

class APIBourseEmploi
# Or wrap things up in your own class
require "json"
require "open-uri"
require "net/http"


  def bourse_emploi
    url = URI("https://bourse-emplois.notaires.fr/api/offre/search?page=1&pageSize=90&sort=DESC&sortField=DATE_ACTUALISATION")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Pragma"] = "no-cache"
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36"
    request["Content-Type"] = "application/json"
    request["Accept"] = "*/*"
    request["Cookie"] = "_ga=GA1.3.1335572239.1606137983; _gid=GA1.3.89168093.1606137983; tartaucitron=!analytics=true!recaptcha=true; Cookie_1=value"
    request.body = "{\"cityFilter\":[],\"departmentFilter\":[],\"functionFilter\":[],\"geolocalisationFilter\":{},\"hasNextPage\":false,\"otherFilter\":{\"workingTime\":[],\"type\":[],\"professionalFormation\":[],\"availability\":[],\"keyWord\":\"\"},\"pageNumber\":1,\"pageSize\":90,\"regionFilter\":[],\"resultCount\":0,\"sortMethod\":\"DESC\",\"launchSearch\":false,\"sortField\":\"DATE_ACTUALISATION\"}"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)
    new_id_array = []
    result["content"].each do |v|
      new_id_array << v["id"]
    end
    final_array = []
    new_id_array.each do |id|
      recruit = transform_json(id)
      final_array << recruit
    end
    post_to_slack(final_array)
    return final_array
  end

  def post_to_slack(final_array)
    RestClient.post ENV["webhook_url_bourse_emploi"], { "text" => final_array.join(", ") }.to_json, {content_type: :json, accept: :json}
  end

  def transform_json(id)
    url2 = URI("https://bourse-emplois.notaires.fr/api/offre/preview/#{id}")
    https = Net::HTTP.new(url2.host, url2.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url2)
    request["Cookie"] = "_ga=GA1.3.1335572239.1606137983; _gid=GA1.3.89168093.1606137983; tartaucitron=!analytics=true!recaptcha=true; Cookie_1=value"
    response2 = https.request(request)
    return_array2 = response2.read_body
    result2 = JSON.parse(return_array2)
    return result2
  end
end
