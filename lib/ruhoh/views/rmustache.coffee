Q = require 'q'
Mustache = require 'mustache'

Mustache.Context::_lookup = Mustache.Context::lookup

# Replace lookup method to catch helper expressions
Mustache.Context::lookup = (key) ->
  debugger
  return @_lookup(key) unless '?' in key
  keys = key.split('?')
  context = keys[0]
  helpers = keys[1...]
  context = if context is '' then @view else @_lookup(context)

  applyHelpers = =>
    while not Q.isPromise(context) and helper = helpers.shift()
      helper_func = @_lookup(helper)
      if Q.isPromise helper_func
        return context = do (context) ->
          helper_func.then (helper_func) -> helper_func(context)
      context = helper_func context

    if Q.isPromise context
      return context.then (ctx) ->
        context = ctx
        applyHelpers()
        
    context

  applyHelpers()

module.exports = Mustache
