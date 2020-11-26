# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "open-uri"

CAT_LIST = ["Avocat", "Huissier", "Notaire", "Administrateur judiciaire", "Commissaire-priseur", "Comptable"]
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

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401302/not.jpg')

  notaire = Category.new(
    name: "Notaire",
    description: "Le notaire authentifie au nom de l'Etat des actes et des contrats et les conserve. Il intervient dans plusieurs domaines : droit de la famille, droit de l’immobilier et du patrimoine. Le conseil aux entreprises devient de plus en plus important."
    )
  notaire.photo.attach(io: file, filename: 'notaire.jpg')
  notaire.save
  puts "#{notaire.name} created"

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401375/marianne_huissier_nki5gp.jpg')

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

  file = URI.open('https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401444/priseur-gd_inll9c.jpg')

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
    description: "Le comptable a la responsabilité de gérer les comptes d'une entreprise et plus globalement sa santé financière. Dans une grande entreprise, il occupe un poste en tant que chargé de comptes clients, fournisseurs ou de la paie."
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

CAT_LIST.each do |element|
  new_eventcat = EventCategory.new(
    title: "#{element} - Les créations de société",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les créations de société")
    )
  new_eventcat.save
  puts new_eventcat
end

CAT_LIST.each do |element|
  new_eventcat1 = EventCategory.new(
    title: "#{element} - Les sociétés qui recrutent",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les sociétés qui recrutent")
    )
  new_eventcat1.save
  puts new_eventcat1
end

CAT_LIST.each do |element|
  new_eventcat2 = EventCategory.new(
    title: "#{element} - Les sociétés qui déménagent",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les sociétés qui déménagent")
    )
  new_eventcat2.save
  puts new_eventcat2
end

CAT_LIST.each do |element|
  new_eventcat3 = EventCategory.new(
    title: "#{element} - Les sociétés qui fusionnent",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les sociétés qui fusionnent")
    )
  new_eventcat3.save
  puts new_eventcat3
end

CAT_LIST.each do |element|
  new_eventcat4 = EventCategory.new(
    title: "#{element} - Les sociétés qui créent leur site internet",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les sociétés qui créent leur site internet")
    )
  new_eventcat4.save
  puts new_eventcat4
end

CAT_LIST.each do |element|
  new_eventcat5 = EventCategory.new(
    title: "#{element} - Les sociétés qui ont ouvert un deuxième siège social",
    category: Category.find_by(name: "#{element}"),
    event: Event.find_by(title: "Les sociétés qui ont ouvert un deuxième siège social")
    )
  new_eventcat5.save
  puts new_eventcat5
end



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
