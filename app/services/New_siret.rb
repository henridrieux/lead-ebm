require "uri"
require "net/http"
require "json"

def new_siret_on_papers(siren)

  url = URI("https://api.pappers.fr/v1/entreprise?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&siren=#{siren}&entreprise_cessee=false")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["Cookie"] = "Cookie_1=value; __cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
  response = https.request(request)
  return_array = response.read_body
  result = JSON.parse(return_array)

  p result["etablissements"].count

end
