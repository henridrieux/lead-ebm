# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "open-uri"

CAT_LIST = ["Avocat", "Huissier", "Notaire", "Administrateur judiciaire", "Commissaire-priseur"]
FREQUENCE_LIST = ["Quotidienne", "Hebdomadaire", "Mensuelle"]

puts "creating categories..."
# if Category.all.count == 0
  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606231560/avocat.jpg')
  avocat = Category.new(
    name: "Avocat",
    description: "L'avocat représente et défend devant les tribunaux ou les cours des particuliers, des entreprises ou des collectivités. Il peut s'agir d'affaires civiles ( divorces, successions, litiges...) ou pénales (contraventions, délits, crimes...). Il peut être également sollicité par les entreprises en tant que conseil.",
  )
  avocat.photo.attach(io: file, filename: 'avocat.jpg')
  avocat.save!
  puts "#{avocat.name} created"
  puts avocat.photo.attached?

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606241120/notaire.jpg')

  notaire = Category.new(
    name: "Notaire",
    description: "Le notaire authentifie au nom de l'Etat des actes et des contrats et les conserve. Il intervient dans plusieurs domaines : droit de la famille, droit de l’immobilier et du patrimoine. Le conseil aux entreprises devient de plus en plus important."
    )
  notaire.photo.attach(io: file, filename: 'notaire.jpg')
  notaire.save
  puts "#{notaire.name} created"

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606241289/huissier.jpg')

  huissier = Category.new(
    name: "Huissier",
    description: "Constater les faits en tant que preuve, informer les intéressés des décisions prises et vérifier leur application sont les principales missions de l'huissier de justice / l'huissière de justice. Après avoir acheté une charge, il/elle est nommé(e) par le garde des Sceaux."
    )
  huissier.photo.attach(io: file, filename: 'huissier.jpg')
  huissier.save
  puts "#{huissier.name} created"

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606241705/administrateur-trice-judiciaire_zzybi1.jpg')

   administrateur_judiciaire = Category.new(
    name: "Administrateur judiciaire",
    description: "L’administrateur judiciaire intervient lorsqu’une entreprise rencontre des difficultés. Il établit un diagnostic et préserve les droits de l'entreprise. Il étudie des solutions de continuation ou de cession de l'entreprise."
    )
  administrateur_judiciaire.photo.attach(io: file, filename: 'Administrateur-judiciaire.jpg')
  administrateur_judiciaire.save
  puts "#{administrateur_judiciaire.name} created"

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606241766/Commissaire-priseur.jpg')

   commissaire_priseur = Category.new(
    name: "Commissaire-priseur",
    description: "Le commissaire-priseur dirige la vente publique aux enchères de biens meubles, la prisée étant l’estimation d’une chose destinée à la vente. La vente aux enchères publiques permet l’établissement du juste prix par la confrontation transparente entre l’offre et la demande."
    )
  commissaire_priseur.photo.attach(io: file, filename: 'Commissaire-priseur.jpg')
  commissaire_priseur.save
  puts "#{commissaire_priseur.name} created"

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606317696/responsable-comptable_mvdrt6.jpg')

   comptable = Category.new(
    name: "Comptable",
    description: "Le comptable a la responsabilité de gérer les comptes d'une entreprise et plus globalement sa santé financière. ... Dans le cadre d'une grande entreprise, le comptable occupe généralement un poste spécialisé en tant que chargé de comptes clients, fournisseurs ou de la paie, ou bien encore auprès du contrôleur de gestion."
    )
  comptable.photo.attach(io: file, filename: 'comptable.jpg')
  comptable.save
  puts "#{comptable.name} created"


# end

puts "creating events..."
#Event.destroy_all
Event.create!(
  title: "Les créations de société",
  description: "Identifier les nouvelles créations d'entreprise",
  frequency: "Quotidienne",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui recrutent",
  description: "Identifier les sociétés qui se développent",
  frequency: "Quotidienne",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui déménagent",
  description: "Identifier les sociétés qui ont déménagé recemment",
  frequency: "Mensuelle",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui fusionnent",
  description: "Identifier les sociétés qui ont fusionné récemment",
  frequency: "Mensuelle",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui créent leur site internet",
  description: "Identifier les sociétés qui créent leur site internet",
  frequency: "Quotidienne",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui ont ouvert un deuxième siège social",
  description: "Identifier les sociétés  qui ont ouvert un deuxième siège social",
  frequency: "Mensuelle",
  query: "SELECT *"
)

puts "creating events_categories..."
puts Event.count
puts Category.count

event4_1 = EventCategory.new(
  title: "Avocat - Les créations de société",
)
event4_1.category = Category.find_by(name: "Avocat")
event4_1.event =  Event.find_by(title: "Les créations de société")
event4_1.save

event4_7 = EventCategory.new(
  title: "Avocat - Les reprises de société",
)
event4_7.category = Category.find_by(name: "Avocat")
event4_7.event =   Event.find_by(title: "Les reprises de société")
event4_7.save

event4_2 = EventCategory.new(
  title: "Notaire - Les sociétés qui recrutent",
)
  event4_2.category_id = Category.find_by(name: "Notaire"),
  event4_2.event = Event.find_by(title: "Les sociétés qui recrutent"),
  event4_2.save

event4_3 = EventCategory.new(
  title: "Notaire - Les créations d'étude",
)
  event4_3.category_id = Category.find_by(name: "Notaire"),
  event4_3.event = Event.find_by(title: "Les créations d'étude"),
  event4_3.save

event4_4 = EventCategory.new(
  title: "Notaire - Reprise d'une étude",
)
  event4_4.category_id = Category.find_by(name: "Notaire"),
  event4_4.event = Event.find_by(title: "Reprise d'une étude"),
  event4_4.save

event4_5 = EventCategory.new(
  title: "Notaire - Les études qui recrutent",
)
  event4_5.category_id = Category.find_by(name: "Notaire"),
  event4_5.event = Event.find_by(title: "Les études qui recrutent"),
  event4_5.save

event4_6 = EventCategory.new(
  title: "Comptable - La création de cabinet",
)
  event4_6.category_id = Category.find_by(name: "Comptable"),
  event4_6.event = Event.find_by(title: "La création de cabinet"),
  event4_6.save

event4_7 = EventCategory.new(
  title: "Comptable - Le recrutement",
)
  event4_7.category_id = Category.find_by(name: "Comptable"),
  event4_7.event = Event.find_by(title: "Le recrutement"),
  event4_7.save

event4_8 = EventCategory.new(
  title: "Comptable - La reprise d'un cabient d'expertise",
)
  event4_8.category_id = Category.find_by(name: "Comptable"),
  event4_8.event = Event.find_by(title: "La reprise d'un cabient d'expertise"),
  event4_8.save

event4_9 = EventCategory.new(
  title: "Administrateur judiciaire - Le recrutement",
)
  event4_9.category_id = Category.find_by(name: "Administrateur judiciaire"),
  event4_9.event = Event.find_by(title: "Le recrutement"),
  event4_9.save


# -----------API 2------------------

def run_pappers(number)
  data2 = APIPapers.new.papers
  data2.first(number).each do |company|

    puts company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]

    input2 = Company.new(
      siren: company["siren"].to_i,
      siret: company["siege"]["siret"].to_i,
      company_name: company["nom_entreprise"],
      creation_date: company["date_immatriculation_rcs"],
      registered_capital: company["capital"].to_i,
      address: company["siege"]["adresse_ligne_1"],
      zip_code: company["siege"]["code_postal"],
      #city: company["siege"]["ville"],
      legal_structure: company["forme_juridique"],
      #manager_name: company["representants"].first["nom_complet"],
      #manager_birth_year: company["representants"].first["date_de_naissance_formate"].last(4).to_i
      #head_count: company["effectif"],
      head_count: company["effectif"],
      naf_code: company["siege"]["code_naf"],
      activities: company["publications_bodacc"].blank? ? nil : company["publications_bodacc"][0]["activite"]
    )
    input2.category = Category.find_by(name: "Notaire")
    input2.save
  end
end
