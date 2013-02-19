class Model
  constructor: (@ruhoh, @pointer) ->
  config: ->
    @ruhoh.db.config(@pointer['resource'])

module.exports = Model
