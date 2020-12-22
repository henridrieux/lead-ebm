require "uri"
require "net/http"
require "json"
require "open-uri"
require 'nokogiri'
require 'clearbit'
require "uri"
require 'httparty'

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
      p recruit
      count += 1
      puts "#{count} / #{result["content"].count}"
      final_array << recruit
    end
    p final_array
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
    p result2
    return result2
  end

  def papers_name(company_name)
    url = "https://api.pappers.fr/v1/recherche?"
    body_request = {
    }
    @options = {
      query: {
        api_token: "3e10f34b388926a0e4030180829391e02b3155bef5f069d5",
        nom_entreprise: company_name,
        entreprise_cessee: false,
        code_naf: "69.10Z"
      },
       headers: {
        pragma: "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36",
        "Content-Type": "application/json",
        accept: "*/*",
        cookie: "__cfduid=d527232f02404f16bcda98a3a52bb74651606225094"
      },
      body: body_request.to_json
    }
    return_body = HTTParty.get(url, @options).body
    result = JSON.parse(return_body)
    # p result
    siret = result["entreprises"][0]["siege"]["siret"]
    siren = result["entreprises"][0]["siren"]
    # p siren.class
    return [siret, siren]
  end
end

APIBourseEmploiNew.new.bourse_emploi(2)
