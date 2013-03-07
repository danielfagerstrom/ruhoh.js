marked = require 'marked'

module.exports =
  extensions: 
    ['.md', '.markdown']
  
  convert: (content) ->
    marked content

