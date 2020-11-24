# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CAT_LIST = ["Avocat", "Huissier", "Notaire", "Administrateur judiciaire", "Commissaire-priseur"]
FREQUENCE_LIST = ["Quotidienne", "Hebdomadaire", "Mensuelle"]

puts "creating categories..."
if Category.all.count == 0
  Category.create!(
    name: "Avocat",
    description: "L'avocat représente et défend devant les tribunaux ou les cours des particuliers, des entreprises ou des collectivités. Il peut s'agir d'affaires civiles ( divorces, successions, litiges...) ou pénales (contraventions, délits, crimes...). Il peut être également sollicité par les entreprises en tant que conseil."
  )
  Category.create!(
    name: "Notaire",
    description: "Le notaire authentifie au nom de l'Etat des actes et des contrats et les conserve. Il intervient dans plusieurs domaines : droit de la famille, droit de l’immobilier et du patrimoine. Le conseil aux entreprises devient de plus en plus important."
  )
  Category.create!(
    name: "Huissier",
    description: "Constater les faits en tant que preuve, informer les intéressés des décisions prises et vérifier leur application sont les principales missions de l'huissier de justice / l'huissière de justice. Après avoir acheté une charge, il/elle est nommé(e) par le garde des Sceaux."
  )
  Category.create!(
    name: "Administrateur judiciaire",
    description: "L’administrateur judiciaire intervient lorsqu’une entreprise rencontre des difficultés. Il établit un diagnostic et préserve les droits de l'entreprise. Il étudie des solutions de continuation ou de cession de l'entreprise."
  )
  Category.create!(
    name: "Commissaire-priseur",
    description: "L’administrateur judiciaire intervient lorsqu’une entreprise rencontre des difficultés. Il établit un diagnostic et préserve les droits de l'entreprise. Il étudie des solutions de continuation ou de cession de l'entreprise."
  )
end

puts "creating events..."
Event.destroy_all
Event.create!(
  title: "Les créations de société",
  description: "Identifier les nouvelles créations d'entreprise"
  # frequency: "Quotidienne",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui recrutent",
  description: "Identifier les sociétés qui se développent"
  # frequency: "Quotidienne",
  query: "SELECT *"
)
Event.create!(
  title: "Les sociétés qui déménagent",
  description: "Identifier les sociétés qui ont déménagé recemment"
  # frequency: "Mensuelle",
  query: "SELECT *"
)

puts "creating events_categories..."

EventCategory.create!(
  category_id: Category.find_by(name: "Avocat"),
  event_id: Event.find_by(title: "Les créations de société"),
  title: "Avocat - Les créations de société"
)

EventCategory.create!(
  category_id: Category.find_by(name: "Notaire"),
  event_id: Event.find_by(title: "Les sociétés qui recrutent"),
  title: "Notaire - Les sociétés qui recrutent"
)


