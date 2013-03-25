_ = require 'underscore'
Mustache = require 'mustache'
Q = require 'q'
friend = require '../friend'
utils = require '../utils'

# module Helpers ; end # FIXME
class MasterView # extends RMustache
  # attr_reader :sub_layout, :master_layout
  # attr_accessor :page_data
  
  constructor: (@ruhoh, pointer_or_content) ->
    if _.isObject pointer_or_content
      @page_data = @ruhoh.db.get(pointer_or_content).then (pd) =>
        pd = {} unless _.isObject pd

        throw new Error "Page #{pointer_or_content['id']} not found in database" unless pd # FIXME: will never happen
        pd

      @_pointer = pointer_or_content
    else
      @_content = pointer_or_content
      @page_data = {}

    @_setup_resources()
  
  render_full: ->
    @_process_layouts().then =>
      Q.when @_expand_layouts(), (expand_layouts) =>
        @render(expand_layouts)

  render_content: ->
    @render('{{{page.content}}}')

  render: (template, ctx) ->
    @ruhoh.db.partials().then (partials) =>
      context = Mustache.Context.make this
      context = context.push ctx if ctx
      Mustache.render template, context, partials

  # Delegate #page to the kind of resource this view is modeling.
  page: ->
    return @_page if @_page
    @_page = if collection = @collection()
      Q.when(@page_data, (page_data) => collection.new_model_view(page_data))
    else
      null

  collection: ->
    @[@_pointer["resource"]]()
  
  urls: ->
    @ruhoh.db.urls()
  
  content: ->
    template = @_content || @ruhoh.db.content(@_pointer)
    Q.when template, (template) =>
      @render(template)

  partial: (name) ->
    @ruhoh.db.partials().get(name).then (p) ->
      friend.say "partial not found: '#{name}'".yellow if p is null
      p + "\n" # newline ensures proper markdown rendering.

  to_json: -> (sub_context) ->
    JSON.stringify sub_context

  to_pretty_json: -> (sub_context) ->
    JSON.stringify sub_context, null, 2
  
  debug: -> (sub_context) ->
    friend.say "?debug:".yellow
    friend.say sub_context.constructor.name.magenta 
    friend.say JSON.stringify(sub_context, null, 2).cyan 

    "<pre>#{sub_context.constructor.name}\n#{JSON.stringify sub_context, null, 2}</pre>"

  raw_code: -> (sub_context) ->
    code = sub_context.replace(/{/g, '&#123;').replace(/}/g, '&#125;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/_/g, "&#95;")
    "<pre><code>#{code}</code></pre>\n"
  
  # My Post Title ===> my-post-title
  # Handy for transforming ids into css-classes in your views.
  # @returns[String]
  to_slug: -> (sub_context) ->
    utils.to_slug(sub_context)
  
  # Public: Formats the path to the compiled file based on the URL.
  #
  # Returns: [String] The relative path to the compiled file for this page.
  compiled_path: ->
    path = decodeURIComponent(@page_data['url']).replace(/^\//g, '') #strip leading slash.
    path = "index.html" if path is ""
    path += '/index.html' unless path.match /\.\w+$/
    path


  # protected
  
  _setup_resources: ->
    for resource in @ruhoh.resources.all()
      do (resource) =>
        @[resource] = =>
          @_load_collection_view_for resource

        @["to_#{resource}"] = (args...) =>
          @_resource_generator_for resource, args...

  # Load collection views dynamically when calling a resources name.
  # Uses method_missing to catch calls to resource namespace.
  # @returns[CollectionView|nil] for the calling resource.
  _load_collection_view_for: (resource) ->
    return null unless @ruhoh.resources.has_collection_view(resource)
    collection_view = @ruhoh.resources.load_collection_view(resource)
    collection_view.master = this
    collection_view.load_promise ? collection_view

  # Takes an Array or string of resource ids and generates the resource objects
  # Uses method_missing to catch calls to 'to_<resource>` contextual helper.
  # @returns[Array] the resource model view objects or raw data hash.
  _resource_generator_for: (resource, sub_context) ->
    collection_view = @_load_collection_view_for(resource)
    _.compact(for id in sub_context
      data = @ruhoh.db[resource][id] || {}
      if collection_view && collection_view['new_model_view']
        collection_view.new_model_view(data)
      else
        data
    )

  _process_layouts: ->
    Q.when(@page_data).then (page_data) =>
      @ruhoh.db.layouts().then (layouts) =>
        if page_data['layout']
          @sub_layout = layouts[page_data['layout']]
          throw new Error "Layout does not exist: #{page_data['layout']}" unless @sub_layout
        else if page_data['layout'] != false
          # try default
          @sub_layout = layouts[@_pointer["resource"]]

        if @sub_layout && @sub_layout['data']['layout']
          @master_layout = layouts[@sub_layout['data']['layout']]
          throw new Error "Layout does not exist: #{@sub_layout['data']['layout']}" unless @master_layout

        page_data['sub_layout'] = @sub_layout?['id']
        page_data['master_layout'] = @master_layout?['id']
        @page_data = page_data
  
  # Expand the layout(s).
  # Pages may have a single master_layout, a master_layout + sub_layout, or no layout.
  _expand_layouts: ->
    if @sub_layout
      layout = @sub_layout['content']

      # If a master_layout is found we need to process the sub_layout
      # into the master_layout using mustache.
      if @master_layout && @master_layout['content']
        layout = @render(@master_layout['content'], {"content": layout})
    else
      # Minimum layout if no layout defined.
      layout = Q.when(@page()).then (page) =>
        if page then '{{{ page.content }}}' else '{{{ content }}}'
    
    layout

module.exports = MasterView
