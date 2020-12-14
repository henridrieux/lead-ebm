require "uri"
require "net/http"
require "json"

def headquarter_count(siren)

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

headquarter_count(525031522)

def company_new_headquarter(company)
  input2 = Company.find_by(siret: company["siege"]["siret"].to_i)
  siret_count_old = input2[:siret_count]
  siret_count_new = company["siege"]["siret_count"]
  if siret_count_old != siret_count_new && !siret_count_old.nil?
    last_moving_date = Date.today
    puts "1 nouvel établissement"
  else
    second_headquarter_date = input2[:second_headquarter_date]
  end
  input2.update(
    siren: company["siren"].to_i,
    siret: company["siege"]["siret"].to_i,
    company_name: company["nom_entreprise"],
    social_purpose: company["objet_social"],
    creation_date: company["siege"]["date_de_creation"],
    registered_capital: company["capital"].to_i,
    address: company["siege"]["adresse_ligne_1"],
    zip_code: company["siege"]["code_postal"],
    city: company["siege"]["ville"],
    last_moving_date: last_moving_date,
    legal_structure: company["forme_juridique"],
    # manager_name: company["representants"].first["nom_complet"],
    # manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
    head_count: company["effectif"],
    naf_code: company["siege"]["code_naf"],
    activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
  )
  cat = check_category(input2)
  input2.category = Category.find_by(name: cat)
  input2.save
  end


