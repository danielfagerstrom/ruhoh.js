BaseModel = require '../../base/model'

# FIXME: should have a generator, but I haven't found it in the rhuho.rb implementation
class Model extends BaseModel
  resource_name: 'media'

module.exports = Model
