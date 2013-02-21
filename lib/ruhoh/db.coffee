_ = require 'underscore'
Q = require 'q'

# Public: Database class for interacting with "data" in Ruhoh.
class DB
  constructor: (@ruhoh) ->
    @_content = {}
    @_config = {}
    @_urls = {}
    @_paths = {}
    @routes = {}

  setup: ->
    for resource in @ruhoh.resources.all()
      do (resource) =>
        @[resource] = => @_data_for resource

  route_add: (route, pointer) ->
    @routes[route] = pointer

  route_delete: (route) ->
    delete @routes[route]

  routes_initialize: ->
    Q.all(
      for r in @ruhoh.resources.acting_as_pages()
        @[r]()
    ).then =>
      @routes

  # Get a data endpoint from pointer
  # Note this differs from update in that
  # it should retrieve the cached version.
  get: (pointer) ->
    name = pointer['resource'].toLowerCase()
    id = pointer['id']
    throw new Error "Invalid data type #{name}" unless @[name]
    @[name]().then (list) =>
      data = list[id]
      if data then Q.resolve(data) else @update(pointer)
  
  # Update a data endpoint
  #
  # name_or_pointer - String, Symbol or pointer(Hash)
  #
  # If pointer is passed, will update the singular resource only.
  # Useful for updating only the resource that have changed.
  #
  # Returns the data that was updated.
  update: (name_or_pointer) ->
    if _.isObject name_or_pointer
      id = name_or_pointer['id']
      if id
        name = name_or_pointer['resource'].toLowerCase()
        if @ruhoh.env == "production" && @["_#{name}"]
          Q.resolve @["_#{name}"][id]
        else
          resource = @ruhoh.resources.load_collection(name)
          resource.generate(id).then (values) =>
            data = values[id]
            endpoint = @["_#{name}"] || {}
            endpoint[id] = data
            data
    else
      name = name_or_pointer.toLowerCase() # name is a stringified constant.
      if @ruhoh.env == "production" && @["_#{name}"]
        Q.resolve @["_#{name}"]
      else
        @ruhoh.resources.load_collection(name).generate().then (data) =>
          @["_#{name}"] = data
          data

  # return a given resource's file content
  content: (pointer) ->
    name = pointer['resource'].toLowerCase() # name is a stringified constant.
    if @ruhoh.env == "production" && @_content["#{name}_#{pointer['id']}"]
      Q.resolve @_content["#{name}_#{pointer['id']}"]
    else
      model = new (@ruhoh.resources.model(name))(@ruhoh, pointer)
      model.content().then (content) =>
        @_content["#{name}_#{pointer['id']}"] = content

  urls: ->
    @_urls["base_path"] = @ruhoh.base_path
    return @_urls if _.keys(@_urls).length > 1 # consider base_url

    for name in @ruhoh.resources.all()
      continue unless @ruhoh.resources.has_collection(name)
      collection = @ruhoh.resources.load_collection(name)
      continue unless collection.url_endpoint
      @_urls[name] = @ruhoh.to_url(collection.url_endpoint())
    
    @_urls

  # Get the config for a given resource.
  config: (name) ->
    name = name.toLowerCase()
    return @_config[name] if @_config[name]
    @_config[name] = @ruhoh.resources.load_collection(name).config()
  
  clear: (name) ->
    @["_#{name}"] = null

  # PROTECTED

  # Lazy-load all data endpoints but cache the result for this cycle.
  _data_for: (resource) ->
    if @["_#{resource}"]
      Q.resolve @["_#{resource}"]
    else
      @update(resource)

module.exports = DB
