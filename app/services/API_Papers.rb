require 'HTTParty'

class APIPapers
# Or wrap things up in your own class

require "json"

  def papers
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        par_page: 100,
        entreprise_cessee: false,
        nom_entreprise: "",
        code_naf: "69.10Z",
        date_creation_min: "01-01-1990"
      },
      headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
      },
      body: body_request.to_json
    }
    response = HTTParty.get(url, @options)
    return_array = response.body
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
    new_id_array.each_with_index do |siret, index|
      recruit = transform_json(siret)
      final_array << recruit
      puts "nous sommes actuellemnt à #{index.fdiv(new_id_array.length)*100}%"
    end
    return final_array
  end

  def transform_json(siret)
    url2 = "https://api.pappers.fr/v1/entreprise?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        siret: "#{siret}"
      },
      headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=da64ed270569726ecde8337ce77714a421606301876"
      },
      body: body_request.to_json
    }
    response2 = HTTParty.get(url2, @options)
    return_array2 = response2.read_body
    result2 = JSON.parse(return_array2)
    return result2
  end
end
