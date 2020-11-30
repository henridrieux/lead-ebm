class APIPapers
# Or wrap things up in your own class
require "json"
require "open-uri"
require "net/http"

  def papers
    url = URI("https://api.pappers.fr/v1/recherche?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&par_page=10000&nom_entreprise&code_naf=69.10Z&departement&code_postal&convention_collective=&categorie_juridique&entreprise_cessee=false&chiffre_affaires_min&chiffre_affaires_max&resultat_min&resultat_max=&date_creation_min=01-09-1980&date_creation_max&tranche_effectif_min=&tranche_effectif_max")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
    response = https.request(request)
    return_array = response.read_body
    result = JSON.parse(return_array)
    new_id_array = []
    new_siege_array = []
    result["entreprises"].each do |v|
      new_siege_array << v["siege"]
    end
    new_siege_array.each do |v|
      new_id_array << v["siret"]
    end
    final_array = []
    new_id_array.each do |siret|
      recruit = transform_json(siret)
      final_array << recruit
    end
    return final_array
  end

  def transform_json(siret)
    url = URI("https://api.pappers.fr/v1/entreprise?api_token=3e10f34b388926a0e4030180829391e02b3155bef5f069d5&siret=#{siret}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
    response2 = https.request(request)
    return_array2 = response2.read_body
    result2 = JSON.parse(return_array2)
    return result2
  end
end

