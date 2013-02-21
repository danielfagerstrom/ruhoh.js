FS = require 'q-io/fs'
BaseModel = require '../../base/model'
utils = require '../../utils'

class Model extends BaseModel
  resource_name: 'partials'

  generate: ->
    dict = {}
    name = utils.chomp @pointer['id'], FS.extension(@pointer['id'])
    FS.read(@pointer['realpath']).then (file) =>
      dict[name] = file
      dict

module.exports = Model
