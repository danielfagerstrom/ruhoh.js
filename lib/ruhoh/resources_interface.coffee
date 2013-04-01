Q = require 'q'
glob = require 'glob'
_ = require 'underscore'
base = require './base'
resources = require './resources'
friend = require './friend'
utils = require './utils'

Whitelist = [
  'collection'
  'collection_view'
  'model'
  'model_view'
  'client'
  'compiler'
  'watcher'
  'previewer'
]

class ResourcesInterface
  constructor: (@ruhoh) ->

  setup: ->
    @_load_discover()

  ensure_setup: ->
    return if @_discover
    throw new Error('ResourcesInterface has not been fully setup. Please call: ResourcesInterface.setup')

  all: ->
    a = _.union @discover(), @registered()
    a.delete("compiled")
    a

  base: ->
    (a for a, m of base when _.isObject(m) and not _.isFunction(m))

  registered: ->
    (key for key of resources)

  # discover all the resource mappings
  _load_discover: ->
    Q.nfcall(glob, '*', cwd: @ruhoh.base, mark: true).then (files) =>
      dirRE = /\/$/
      @_discover =
        (file.replace(dirRE, '') for file in files when file.match(dirRE) and not (file in ["plugins"]))
      
  discover: ->
    @ensure_setup()
    @_discover

  acting_as_pages: ->
    r = _.difference @registered(), ["pages", "posts"] # registered non-pages

    for resource, config of @ruhoh.config()
      continue if resource in ["theme", "compiled"]
      continue if (config && config["use"] && config["use"] != "pages")
      continue if resource in r
      continue unless resource in @discover()
      resource

  non_pages: ->
    _.difference @all(), @acting_as_pages(), ["theme"]

  exists: (name) ->
    name in @all()

  exist: (name) -> @exists(name)

  # PROTECTED

  # Load and cache a given resource class.
  # This allows you to work with single object instance and perform
  # persistant mutations on it if necessary.
  # TODO: Kind of ugly, maybe a better way to do this. Singleton?
  # @returns[Class Instance] of the resource and class_name given.
  _load_class_instance_for: (class_name, args...) ->
    [resource, opts] = args
    
    var_ = "_#{resource}_#{class_name}"
    if @[var_]
      @[var_]
    else
      if class_name == "collection"
        i = new (@collection(resource))(@ruhoh)
        i.resource_name = resource
        instance = i
      else if class_name in ["collection_view", "watcher", "compiler"]
        collection = @_load_class_instance_for("collection", resource)
        instance = new (@[class_name](resource))(collection)
      else if class_name == "client"
        collection = @_load_class_instance_for("collection", resource)
        instance = new (@[class_name](resource))(collection, opts)
      else
        instance = new (@[class_name](resource))(@ruhoh)

      @[var_] = instance

  # Load the registered resource else default to Pages if not configured.
  # @returns[Constant] the resource's module namespace
  _get_module_namespace_for: (resource) ->
    type = @ruhoh.config()[resource]?["use"]
    if type
      if type in @registered()
        resources[type]
      else if type in @base()
        base[type]
      else
        klass = @_camelize(type)
        friend.say -> @red "#{resource} resource set to use:'#{type}' in config.yml but Ruhoh::Resources::#{klass} does not exist."
        process.exit 1
    else
      if resource in @registered()
        resources[resource]
      else
        base.pages

  _camelize: (name) ->
    @constructor._camelize name

  @_camelize: (name) ->
    utils.camelize name


for method_name in Whitelist
  do (method_name) ->
    ResourcesInterface::[method_name] = (name) ->
      @_get_module_namespace_for(name)[@_camelize(method_name)]

    ResourcesInterface::["has_#{method_name}"] = (name) ->
      @_get_module_namespace_for(name)[@_camelize(method_name)]?

    ResourcesInterface::["load_#{method_name}"] = (args...) ->
      @_load_class_instance_for(method_name, args...)


module.exports = ResourcesInterface
