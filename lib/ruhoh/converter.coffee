FS = require 'q-io/fs'
converters = require './converters'

Converter =
  convert: (content, id) ->
    extension = FS.extension(id).toLowerCase()
    
    for c, converter of converters when converter.convert and converter.extensions and extension in converter.extensions
      return converter.convert(content)

    content
  
  # Return an Array of all regestered extensions
  extensions: ->
    [].concat (converter.extensions for c, converter of converters when converter.extensions)...

module.exports = Converter
