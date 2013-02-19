Ruhoh = require '../ruhoh'

module.exports =
  init: (opts) ->
    return @ruhoh if @ruhoh
    opts ?= source: '../pkg/ruhoh.com/' # FIXME: just during development
    @ruhoh = new Ruhoh()
    @ruhoh.env ||= 'development'
    @ruhoh.setup_all(opts).then =>
      @ruhoh

  reload: ->
    @ruhoh = null
    @init()

  