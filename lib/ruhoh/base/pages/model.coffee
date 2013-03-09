YAML = require 'js-yaml'
FS = require 'q-io/fs'
moment = require 'moment'
_ = require 'underscore'
BaseModel = require '../model'
utils = require '../../utils'

class Model extends BaseModel
  resource_name: 'pages'

  FMregex = /^(---\s*\n[^]*?\n?)^(---\s*$\n?)/m
  DateMatcher = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
  Matcher = /^(.+\/)*(.*)(\.[^.]+)$/

  # Generate this filepath
  # Returns data to be registered to the database
  generate: ->
    @parse_page_file().then (parsed_page) =>
      data = parsed_page['data']

      filename_data = @parse_page_filename(@pointer['id'])

      data['pointer'] = @pointer
      data['id'] = @pointer['id']

      data['title'] = data['title'] || filename_data['title']
      data['date'] ?= filename_data['date']?.toString() ? ""
      data['url'] = @permalink(data)
      data['layout'] ?= @config()['layout']

      # Register this route for the previewer
      @ruhoh.db.route_add(data['url'], @pointer)

      (result = {})["#{@pointer['id']}"] = data
      result

  content: ->
    @parse_page_file().get 'content'

  parse_page_file: ->
    filepath = @pointer['realpath']
    FS.exists(filepath)
    .then( (exists) =>
      throw new Error "File not found: #{filepath}" unless exists
      FS.read(filepath)
    ).then( (page) =>
      front_matter = page.match(FMregex)
      try
        data = if front_matter
          (YAML.load(front_matter[0].replace(/---\n/g, "")) || {})
        else
          {}
        {
          data: data
          content: page.replace(FMregex, '')
        }
      catch e
        @ruhoh.constructor.log.error("ERROR in #{filepath}: #{e.message}")
        null
    )

  parse_page_filename: (filename) ->
    data = filename.match(DateMatcher)
    data ?= filename.match(Matcher)
    return {} unless data

    if filename.match DateMatcher
      {
        "path": data[1]
        "date": data[2]
        "slug": data[3]
        "title": @to_title(data[3])
        "extension": data[4]
      }
    else
      {
        "path": data[1]
        "slug": data[2]
        "title": @to_title(data[2])
        "extension": data[3]
      }

  # my-post-title ===> My Post Title
  to_title: (file_slug) ->
    if file_slug == 'index' && @pointer['id'].indexOf('/') != -1
      file_slug = (parts = @pointer['id'].split('/'))[parts.length-2]

    # FIXME: /[^\p{Word}+]/u in original
    file_slug.replace(/[\W+]/g, ' ').replace(/\b\w/g, (c) -> c.toUpperCase())

  # Another blatently stolen method from Jekyll
  # The category is only the first one if multiple categories exist.
  permalink: (page_data) ->
    format = page_data['permalink'] || @config()['permalink']
    format ||= "/:path/:filename"

    url = if ':' in format
      title = utils.to_url_slug(page_data['title'] ? '')
      filename = FS.base(page_data['id'])
      if category = page_data['categories']
        category = [category] unless _.isArray category
        category = category[0]
        category = (utils.to_url_slug(c) for c in category.split('/')).join('/') if category
      relative_path = FS.directory(page_data['id'])
      relative_path = "" if relative_path == "."
      data = {
        "title": title
        "filename": filename
        "path": FS.join(@pointer["resource"], relative_path)
        "relative_path": relative_path
        "categories": category || ''
      }

      date = moment(page_data['date'])
      if date?.isValid()
        _.extend data, {
          "year"       : date.format("YYYY")
          "month"      : date.format("MM")
          "day"        : date.format("DD")
          "i_day"      : date.date()
          "i_month"    : date.month() + 1
        }

      for pattern, value of data
        format = format.replace new RegExp(":#{utils.escapeRegExp pattern}", "g"), value
      format.replace(/\/+/g, "/")
    else
      # Use the literal permalink if it is a non-tokenized string.
      (encodeURIComponent p for p in format.replace(/^\//g, '').split('/')).join('/')

    # Only recognize extensions registered from a 'convertable' module.
    # This means 'non-convertable' extensions should pass-through.
    #
    # FIXME: converter not implemented yet
    # if Ruhoh::Converter.extensions.include?(File.extname(url)) :)
    #   url = url.gsub(%r{#\{File.extname(url)}$}, '.html') :)
    # end :)

    unless (page_data['permalink_ext'] || @config()['permalink_ext'])
      url = url.replace(/index.html$/g, '').replace(/\.html$/, '')

    url = '/' unless url

    @ruhoh.to_url(url)

module.exports = Model
