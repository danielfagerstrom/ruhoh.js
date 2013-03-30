_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
glob = require 'glob'
utils = require '../utils'

class Collection
  constructor: (@ruhoh) ->

  namespace: ->
    utils.underscore @resource_name

  # The default glob for finding files.
  # Every file in all child directories.
  glob: ->
    "**/*"
  
  # Default paths to the 3 levels of the cascade.
  paths: ->
    a = [
      { name: "system", path: @ruhoh.paths.system }
      { name: "base", path: @ruhoh.paths.base }
    ]
    a.push { name: "theme", path: @ruhoh.paths.theme } if @ruhoh.paths.theme
    a

  # Does this resource have any valid paths to process?
  # A valid path may exist on any of the cascade levels.
  # False means there are no directories on any cascade level.
  # @returns[Boolean]
  hasPaths: ->
    Q.all(
      for path in (h.path for h in @paths())
        do (path) =>
          FS.isDirectory FS.join(path, @namespace())
    ).then (hasDirectories) ->
      _.some hasDirectories

  config: ->
    config = (@ruhoh.config()[@resource_name] ?= {})
    unless _.isObject config
      @ruhoh.log.error("'#{@resource_name}' config key in config.yml is a #{typeof config}; it needs to be a Hash (object).")
    config

  # Generate all data resources for this data endpoint.
  #
  # id - (Optional) String or Array.
  #   Generate a single data resource at id.
  # block - (Optional) block.
  #   Implement custom validation logic by passing in a block. The block is given (id, self) as args.
  #   Return true/false for whether the file is valid/invalid.
  #   Example:
  #     Generate only files startng with the letter "a" :
  #     generate {|id| id.start_with?("a") }
  #
  # @returns[Hash(dict)] dictionary of data hashes {"id" => {<data>}}
  generate: (id=null, block) ->
    dict = {}
    @files(id, block).then (files) =>
      Q.all(
        for pointer in files
          do (pointer) =>
            pointer["resource"] = @resource_name
            if @ruhoh.resources.has_model(@resource_name)
              model = new (@ruhoh.resources.model(@resource_name))(@ruhoh, pointer)
              model.generate()
            else
              (r = {})[pointer['id']] = pointer
              Q.resolve(r)
      ).then (results) =>
        for result in results
          _.extend dict, result
        utils.report(@resource_name, dict, [])
        dict

  # Collect all files (as mapped by data resources) for this data endpoint.
  # Each resource can have 3 file references, one per each cascade level.
  # The file hashes are collected in order 
  # so they will overwrite eachother if found.
  # Returns Array of file data hashes.
  # 
  # id - (Optional) String or Array.
  #   Collect all files for a single data resource.
  #   Can be many files due to the cascade.
  # block - (Optional) block.
  #   Implement custom validation logic by passing in a block. The block is given (id, self) as args.
  #   Return true/false for whether the file is valid/invalid.
  #   Note it is preferred to pass the block to #generate as #files is a low-level method.
  #
  # Returns Array of file hashes.
  files: (id=null, block) ->
    Q.all(
      for path in (h.path for h in @paths())
        do (path) =>
          namespaced_path = FS.join(path, @namespace())
          pattern = id or @glob()
          Q.nfcall(glob, pattern, cwd: namespaced_path, mark: true).then (files) =>
            for id in files when (if block? then block(id, this) else @_valid_file id)
              {
                id: id
                realpath: FS.absolute(FS.join namespaced_path, id)
                resource: @resource_name
              }
    ).then (files) =>
      [].concat files...

  _valid_file: (filepath) ->
    return false if filepath[filepath.length-1] is '/' # directory
    for regex in @config()['exclude'] or []
      return false if filepath.match regex
    true


module.exports = Collection
