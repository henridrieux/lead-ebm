# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "open-uri"

CAT_LIST = ["Avocat", "Huissier", "Notaire", "Administrateur judiciaire", "Commissaire-priseur", "Comptable", 'Médecin']

cat_1 = {
  name: "Avocat",
  description: "L'avocat représente et défend devant les tribunaux ou les cours \
    des particuliers, des entreprises ou des collectivités. Il peut s'agir d'affaires \
    civiles ( divorces, successions, litiges...) ou pénales (contraventions, délits, \
    crimes...). Il peut être également sollicité par les entreprises en tant que conseil.",
  color_code: "#FDBF3F",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606231560/avocat.jpg',
  filename: 'avocat.jpg'
}
cat_2 = {
  name: "Notaire",
  description: "Le notaire authentifie au nom de l'Etat des actes \
    et des contrats et les conserve. Il intervient dans plusieurs domaines \
    : droit de la famille, droit de l’immobilier et du patrimoine. Le conseil \
    aux entreprises devient de plus en plus important.",
  color_code:"#19B8D2",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401988/5edf7c0886688_20_logo_notaire-4167128_upo2is.jpg',
  filename: 'notaire.jpg'
}
cat_3 = {
  name: "Huissier",
  description: "Constater les faits en tant que preuve, informer les intéressés \
    des décisions prises et vérifier leur application sont les principales missions \
    de l'huissier de justice / l'huissière de justice. Après avoir acheté une charge, \
    il/elle est nommé(e) par le garde des Sceaux.",
  color_code:"#4E0CB2",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401921/REFlex_090924CM02_0009_1_akxt9p.jpg',
  filename: 'huissier.jpg'
}
cat_4 = {
  name: "Administrateur judiciaire",
  description: "L’administrateur judiciaire intervient lorsqu’une entreprise \
    rencontre des difficultés. Il établit un diagnostic et préserve les droits \
    de l'entreprise. Il étudie des solutions de continuation ou de cession de \
    l'entreprise.",
  color_code:"#F2D8D7",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606241705/administrateur-trice-judiciaire_zzybi1.jpg',
  filename: 'administrateur-judiciaire.jpg'
}
cat_5 = {
  name: "Commissaire-priseur",
  description: "Le commissaire-priseur dirige la vente publique aux enchères de biens \
    meubles, la prisée étant l’estimation d’une chose destinée à la vente. La vente \
    aux enchères publiques permet l’établissement du juste prix par la confrontation \
    transparente entre l’offre et la demande.",
  color_code:"#60B96E",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606401444/priseur-gd_inll9c.jpg',
  filename: 'Commissaire-priseur.jpg'
}
cat_6 = {
  name: "Greffier",
  description: "Le greffier de tribunal de commerce est présent au tribunal pour assurer \
    les services administratifs, l'accueil des justiciables et des entreprises, et assister \
    le juge dans la conservation des actes (enrôlement des affaires, assistance à l'audience, \
    mise en forme des décisions…).",
  color_code:"#5A1552",
  url: 'https://res.cloudinary.com/dnpdonlro/image/upload/v1606836668/extrait-avoir_greffier_nh53gv.jpg',
  filename: 'greffier.jpg'
}
cat_7 = {
  name: "Comptable",
  description: "Le comptable a la responsabilité de gérer les comptes d'une entreprise \
    et plus globalement sa santé financière. Dans une grande entreprise, il occupe \
    un poste en tant que chargé de comptes clients, fournisseurs ou de la paie.",
  color_code:"#D22C51",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1606404077/comptable.jpg',
  filename: 'Comptable.jpg'
}
cat_8 = {
  name: "Médecin",
  description: "Un médecin est un professionnel de la santé titulaire d'un diplôme de docteur
   en médecine ou, en France d'un diplôme d'État de docteur en médecine. ",
  color_code:"#54e346",
  url: 'https://res.cloudinary.com/dpco9ylg1/image/upload/v1607764870/Medecin-geriatre-850x523_ivvnjb.jpg',
  filename: 'Médecin.jpg'
}

def seed_category(cat)
  if Category.find_by(name: cat[:name])
    cat_to_update = Category.find_by(name: cat[:name])
    cat_to_update.update(
      name: cat[:name],
      description: cat[:description],
      color_code: cat[:color_code]
      )
    file = URI.open(cat[:url])
    if cat_to_update.photo.attached?
      cat_to_update.photo.purge
    end
    cat_to_update.photo.attach(io: file, filename: cat[:filename])
    cat_to_update.save
    puts "Category #{cat_to_update.name} updated"
  else
    new_cat = Category.new(
      name: cat[:name],
      description: cat[:description],
      color_code: cat[:color_code])
    file = URI.open(cat[:url])
    new_cat.photo.attach(io: file, filename: cat[:filename])
    new_cat.save
    puts "Category #{new_cat.name} created"
  end
end

puts "creating cats..."

ALL_CATS = [cat_1, cat_2, cat_3, cat_4, cat_5, cat_6, cat_7, cat_8]
ALL_CATS.each do |cat|
  p cat[:url]
  seed_category(cat)
end

puts "#{Category.count} cats in db "

# ----------- CREATING EVENTS ----------------

event_1 = {
  title: "Créations de société",
  description: "Identifier les nouvelles créations d'entreprise",
  frequency: "sur 3 mois",
  color_code: "#1A6EFC",
  query: "creation_date > ?",
  query_params: "90",
  url_icon:"https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/new_company_rwmoj9.png"
}
event_2 = {
  title: "Sociétés qui recrutent",
  description: "Identifier les sociétés qui se développent",
  frequency: "sur 1 mois",
  color_code: "#28B6A4",
  query: "recruitments.id > 0 AND recruitments.created_at > ?",
  query_params: "30",
  url_icon: "https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/recruitment_xqufo0.png"
}
event_3 = {
  title: "Sociétés qui déménagent",
  description: "Identifier les sociétés qui ont déménagé recemment",
  frequency: "sur 2 mois",
  color_code: "#BF73DB",
  query: "last_moving_date > ?",
  query_params: "60",
  url_icon: "https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/moving_x4ylvr.png"
}
event_4 = {
  title: "Sociétés qui fusionnent",
  description: "Identifier les sociétés qui ont fusionné récemment",
  frequency: "sur 1 an",
  color_code: "#B6BAEA",
  query: "fusion_date > ?",
  query_params: "360",
  url_icon:"https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/fusion_ftodyw.png"
}
event_5 = {
  title: "Sociétés qui créent leur site internet",
  description: "Identifier les sociétés qui créent leur site internet",
  frequency: "sur 3 mois",
  color_code: "#FC454A",
  query: "website_date > ?",
  query_params: "90",
  url_icon: "https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/website_efa8la.png"
}
event_6 = {
  title: "Ouvertures d'un nouvel établissement",
  description: "Identifier les sociétés qui ont ouvert un deuxième siège social",
  frequency: "sur 1 an",
  color_code: "#F2C94D",
  query: "second_headquarter_date > ?",
  query_params: "30",
  url_icon: "https://res.cloudinary.com/dpco9ylg1/image/upload/v1606816711/etablissement_j5ithk.png"
}


def seed_event(event)
  if Event.find_by(title: event[:title])
    ev_to_update = Event.find_by(title: event[:title])
    ev_to_update.update(event)
    puts "Event #{ev_to_update.title} updated"
  else
    new_event = Event.new(event)
    new_event.save
    puts "Event #{new_event.title} created"
  end
end

puts "creating events..."

ALL_EVENTS = [event_1, event_2, event_3, event_4, event_5, event_6]
ALL_EVENTS.each do |event|
  seed_event(event)
end

puts "#{Event.count} events in db "

# ----------- CREATING EVENTCATEGORIES ----------------

puts "creating events_categories..."

Category.all.each do |cat|
  Event.all.each do |event|
    if EventCategory.find_by(event: event.id, category: cat.id)
      event_cat = EventCategory.find_by(event: event.id, category: cat.id)
      event_cat.update(
        title: "#{cat.name} - #{event.title}",
        )
    else
      new_eventcat = EventCategory.new(
        title: "#{cat.name} - #{event.title}",
        category: Category.find(cat.id),
        event: Event.find(event.id)
        )
      new_eventcat.save
    end
  end
end

puts "#{EventCategory.count} event_categories in db "

# ----------- XXXXXX ----------------


