require 'colors'
util = require 'util'
module.exports =
  error: (string) ->
    util.error string.red
    process.exit -1
    