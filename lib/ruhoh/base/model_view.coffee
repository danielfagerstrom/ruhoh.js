_ = require 'underscore'
utils = require '../utils'

class ModelView
  # attr_accessor :collection, :master
  
  constructor: (@ruhoh, data={}) ->
    if _.isObject(data)
      for key, value of data
        # tags and catgories are overrided in pages model view and needs to be handled by functions
        key = "_#{key}" if key in ['tags', 'categories']
        @[key] = value

  categories: -> @_categories
  tags: -> @_tags
  
  compare: (other) ->
    # id <=> other.id
    # No model id in javascript
    utils.compare @toString(), other.toString()

  @compare: (a, b) ->
    a.compare b

module.exports = ModelView
