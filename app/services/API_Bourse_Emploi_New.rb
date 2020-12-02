require 'rest-client'
require 'httparty'
require "json"

class APIBourseEmploiNew

  def bourse_emploi(number)
    url = "https://bourse-emplois.notaires.fr/api/offre/search"
    body_request = {
      cityFilter: [],
      departmentFilter: [],
      functionFilter: [],
      geolocalisationFilter: {},
      hasNextPage: false,
      otherFilter: {
        workingTime: [],
        type: [],
        professionalFormation: [],
        availability: [],
        keyWord: ""
      },
      pageNumber:1,
      pageSize:number,
      regionFilter: [],
      resultCount: 0,
      sortMethod: "DESC",
      launchSearch: false,
      sortField: "DATE_ACTUALISATION"
    }
    @options = {
      query: {
        page: 1,
        pageSize: number,
        sort: "DESC",
        sortField: "DATE_ACTUALISATION"
      },
      headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "_ga=GA1.3.1364850714.1606138104; _gid=GA1.3.828954730.1606138104; tartaucitron=!analytics=true!recaptcha=true"
      },
      body: body_request.to_json
    }
    response = HTTParty.post(url, @options)
    return_array = response.body
    result = JSON.parse(return_array)
    new_id_array = []
    result["content"].each do |v|
      new_id_array << v["id"]
    end
    final_array = []
    count = 0
    new_id_array.each do |id|
      recruit = transform_json(id)
      recruit["siret"] = papers_name(recruit["officeName"])[0]
      recruit["siren"] = papers_name(recruit["officeName"])[1]
      # p recruit
      count += 1
      puts "#{count} / #{result["content"].count}"
      final_array << recruit
    end
    return final_array
  end

  def transform_json(id)
    url2 = "https://bourse-emplois.notaires.fr/api/offre/preview/#{id}"
    body_request = {
    }
    @options = {
      query: {
      },
      headers: {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "_ga=GA1.3.1335572239.1606137983; _gid=GA1.3.89168093.1606137983; tartaucitron=!analytics=true!recaptcha=true; Cookie_1=value"
      },
      body: body_request.to_json
    }
    response2 = HTTParty.get(url2, @options)
    return_array2 = response2.body
    result2 = JSON.parse(return_array2)
    # new_company_name = papers_name(company_name)
    return result2
  end

  def papers_name(company_name)
    url2 = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        code_naf: "69.10Z",
        nom_entreprise: company_name.gsub(",", "")
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
    return_body_siret = HTTParty.get(url2, @options).read_body
    result2 = JSON.parse(return_body_siret)
    siret = result2["entreprises"][0]["siege"]["siret"]
    siren = result2["entreprises"][0]["siren"]
    return [siret, siren]
  end
end



