Q = require 'q'
FS = require 'q-io/fs'
glob = require 'glob'
_ = require 'underscore'
BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'widgets'
  
  constructor: (@ruhoh) ->
    @path = FS.join @ruhoh.paths.base, "widgets"
    @system_path = FS.join @ruhoh.paths.system, "widgets"

  url_endpoint: ->
    "/assets/widgets"

  # @returns[Array] registered widget names.
  widgets: ->
    dirRE = /\/$/
    Q.all(
      for path_ in (h.path for h in @paths())
        do (path_) =>
          namespaced_path = FS.join path_, @namespace()
          Q.nfcall(glob, '*', cwd: namespaced_path, mark: true).then (files) =>
            (file.replace(dirRE, '') for file in files when file.match(dirRE))
    ).then (files) =>
      _.union files...

    
module.exports = Collection
