define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/parse"
  "cs!utils/log"
  "cs!urls"
  "yaml"
], ($, _, Backbone, Parse, Log, Urls) ->

  Ruhoh = @Ruhoh
  
  # Pages Dictionary is a hash representation of all pages in the app.
  # This is used as the primary pages database for the application.
  # A page is referenced by its unique id attribute .
  # When working with pages you only need to reference its id.
  # Valid id nodes are expanded to the full page object via the dictionary.
  Backbone.Model.extend

    generate2: ->
      Ruhoh.ensure_setup()
      dictionary = {}

      @files().pipe((filenames) =>
        readFiles = for filename in filenames
          do (filename) ->
            $.get(filename)
            .pipe (content) ->
              {filename, content}
          
        $.when(readFiles...)
        .pipe((results...) =>
          for {filename, content} in results
            data = Parse.frontMatter(content, filename)
            id = @make_id(filename)
            
            data['id']     = id
            data['url']    = @permalink(data)
            data['title']  = data['title'] || @to_title(filename)
            unless data['layout']
              data['layout'] = Ruhoh.config.get('pages_layout')
            
            dictionary[id] = data
            
          # Ruhoh::Utils.report('Pages', dictionary, [])  
          dictionary
        )
      )
      
    files: ->
      $.get("?pattern=#{Ruhoh.paths.pages}/**/*.*")
      .pipe((files) =>
        _.filter files, @is_valid_page
      )

    is_valid_page: (filepath) ->
      return false if filepath[filepath.length - 1] is '/'
      return false if filepath[0] is '.'
      for regex in Ruhoh.config.get('pages_exclude')
        return false if regex.test filepath
      true

    make_id: (filename) ->
      filename.replace(Ruhoh.paths.pages + '/', '')
      
    to_title: (filename) ->
      # basename w.o. extension
      name = (p = filename.id.split('/'))[p.length - 1].replace(/\.[^.]+$/,'')
      name = (f = filename.split('/'))[f.length - 2] if name == 'index' && filename.indexOf('/') != -1
      name.replace(/[^\w+]/g, ' ').replace(/\b\w/g, (c) -> c.toUpperCase())
    
    # Build the permalink for the given page.
    # Only recognize extensions registered from a 'convertable' module.
    # This means 'non-convertable' extensions should pass-through.
    #
    # Returns [String] the permalink for this page.
    permalink: (page) ->
      ext = page.id.replace(/^.*(\.[^.]+)$/, '$1')
      name = page.id.replace(/\.[^.]+$/, '')
      # FIXME
      # ext = '.html' if ext in Converter.extensions
      url = (Urls.to_url_slug(p) for p in name.split('/')).join('/')
      url = "#{url}#{ext}".replace(/index\.html$/, '')
      if page['permalink'] == 'pretty' || Ruhoh.config.get('pages_permalink') == 'pretty'
        url = url.replace(/\.html$/, '')
      
      url = '/' unless url
      Urls.to_url(url)


    generate: ->
      @fetch dataType: "html", cache: false

    url: ->
      @config.getDataPath "/database/pages_dictionary.yml"

    parse: (response) ->
      data = jsyaml.load(response)
      # Need to append the page id to urls for client-side rendering.
      # i.e. We need to tell javascript where the file is.
      for id of data
        data[id]["url"] += ("?path=" + @config.fileJoin(@config.get("pagesDirectory"), id))
      @set data
      @attributes
