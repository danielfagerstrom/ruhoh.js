YAML = require 'js-yaml'
FS = require 'q-io/fs'
BaseModel = require '../../base/model'
utils = require '../../utils'
log = require '../../logger'

class Model extends BaseModel
  resource_name: 'layouts'

  generate: ->
    dict = {}
    id = FS.base(@pointer['id'], FS.extension(@pointer['id']))
    @parse_layout_file(@pointer['realpath']).then (data) =>
      data['id'] = id
      dict[id] = data
      dict
  
  parse_layout_file: (args...) ->
    path = FS.join args...
    FS.exists(path)
    .then((exists) =>
      throw new Error "Layout file not found: #{path}" unless exists
      FS.read(path)
    ).then((page) =>
      data = {}
      try
        front_matter = page.match(utils.FMregex)
        if front_matter
          data = YAML.load(front_matter[0].replace(/---\n/g, "")) || {}
        
        { 
          "data": data,
          "content": page.replace(utils.FMregex, '')
        }
      catch e
        log.error("ERROR in #{path}: #{e.message}")
        null
    )

module.exports = Model
