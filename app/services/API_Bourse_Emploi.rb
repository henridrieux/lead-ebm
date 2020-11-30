require 'rest-client'
require 'HTTParty'

class APIBourseEmploi

require "json"

  def bourse_emploi
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
      pageSize:90,
      regionFilter: [],
      resultCount: 0,
      sortMethod: "DESC",
      launchSearch: false,
      sortField: "DATE_ACTUALISATION"
    }
    @options = {
      query: {
        page: 1,
        pageSize: 90,
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
    new_id_array.each do |id|
      recruit = transform_json(id)
      final_array << recruit
    end
    post_to_slack(final_array)
    return final_array

  end

 # def post_to_slack(event_category)
    #hash = event_category.json_leads
    #hash[:leads].each do |lead|
   # RestClient.post "https://hooks.slack.com/services/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",
                   # {"type" => 'mrkdwn',
                   # "text" => "*#{hash[:category_name]} - #{hash[:event_title]}*",
                    #{}"blocks" => lead[:address],
                    #}.to_json,
                    #{ content_type: "application/json", accept: :json }
    #end
 # end

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
    return result2
  end
end

