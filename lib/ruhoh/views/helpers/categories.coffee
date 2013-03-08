_ = require 'underscore'

categories =
  # Category dictionary
  categories: ->
    categories_url = null
    for url in [@ruhoh.to_url("categories"), @ruhoh.to_url("categories.html")]
      categories_url = url
      break if url of @ruhoh.db.routes

    @ruhoh.db[@resource_name]().then (resources) =>
      dict = {}
      for key, resource of resources when (cats = resource['categories'])
        cats = [cats] unless _.isArray cats
        for cat in cats
          # cat = [cat] unless _.isArray cat; cat = cat.join('/') # FIXME: there is something like this in Ruho.rb, don't understand why
          if dict[cat]
            dict[cat]['count'] += 1
          else
            dict[cat] = { 
              'count': 1, 
              'name': cat, 
              'url': "#{categories_url}##{cat}-ref"
            }
            dict[cat][@resource_name] = []

          dict[cat][@resource_name].push resource['id']
      dict["all"] = (cat for key, cat of dict)
      dict
        
  # Convert single or Array of category ids (names) to category hash(es).
  to_categories: (sub_context) ->
    sub_context = [sub_context] unless _.isArray sub_context
    @categories().then (categories) ->
      _.compact(categories[id] for id in sub_context)

module.exports = categories
