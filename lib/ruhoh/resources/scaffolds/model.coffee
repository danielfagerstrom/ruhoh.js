FS = require 'q-io/fs'
BaseModel = require '../../base/model'

class Model extends BaseModel
  resource_name: 'scaffolds'

  generate: ->
    dict = {}
    FS.read(@pointer['realpath']).then (file) =>
      dict[@pointer['id']] = file
      dict

module.exports = Model
