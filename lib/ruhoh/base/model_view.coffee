_ = require 'underscore'
utils = require '../utils'

class ModelView
  # attr_accessor :collection, :master
  
  constructor: (@ruhoh, data={}) ->
    _.extend this, data if _.isObject(data)
  
  compare: (other) ->
    # id <=> other.id
    # No model id in javascript
    utils.compare @toString(), other.toString()

  @compare: (a, b) ->
    a.compare b

module.exports = ModelView
