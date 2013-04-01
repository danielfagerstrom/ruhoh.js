class Compiler
  # attr_reader :collection

  constructor: (@collection) ->
    @ruhoh = @collection.ruhoh

  resource_name: ->
    @collection.resource_name

module.exports = Compiler
