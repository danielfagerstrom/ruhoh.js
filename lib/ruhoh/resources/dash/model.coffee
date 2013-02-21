Q = require 'q'
PagesModel = require '../../base/pages/model'

class Model extends PagesModel
  resource_name: 'dash'

  generate: ->
    Q.resolve @pointer

module.exports = Model
