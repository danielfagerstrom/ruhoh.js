PagesModel = require '../../base/pages/model'

class Model extends PagesModel
  resource_name: 'widgets'

  generate: ->
    @parse_page_file()
    .get('data').then (data) =>
      data['pointer'] = @pointer
      data['id'] = @pointer['id']

      (r={})[@pointer['id']] = data
      r

module.exports = Model
