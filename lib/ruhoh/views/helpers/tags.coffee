_ = require 'underscore'

tags =
  # Generate the tags dictionary
  tags: ->
    tags_url = null
    for url in [@ruhoh.to_url("tags"), @ruhoh.to_url("tags.html")]
      tags_url = url
      break if url of @ruhoh.db.routes

    @ruhoh.db[@resource_name]().then (resources) =>
      dict = {}
      for key, resource of resources when (tags = resource['tags'])
        tags = [tags] unless _.isArray tags
        for tag in tags
          if dict[tag]
            dict[tag]['count'] += 1
          else
            dict[tag] = { 
              'count': 1, 
              'name': tag,
              'url': "#{tags_url}##{tag}-ref"
            }
            dict[tag][@resource_name] = []

          dict[tag][@resource_name].push resource['id']
      dict["all"] = (tag for key, tag of dict)
      dict
  
  # Convert single or Array of tag ids (names) to tag hash(es).
  to_tags: (sub_context) ->
    sub_context = [sub_context] unless _.isArray sub_context
    @tags().then (tags) ->
      _.compact(tags[id] for id in sub_context)

module.exports = tags
