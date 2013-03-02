FS = require 'q-io/fs'
HTTP = require 'q-io/http'
Apps = require 'q-io/http-apps'
Ruhoh = require '../../ruhoh'

preview = (opts={}) ->
  opts.watch ||= true
  opts.env ||= 'development'
  
  ruhoh = new Ruhoh()
  ruhoh._env = opts.env # FIXME ruhoh env needs to be writable
  ruhoh.setup_all(opts).then( ->
    # initialize the routes dictionary for all page resources.
    ruhoh.db.routes_initialize()
  ).then ->
    # Ruhoh::Program.watch(ruhoh) if opts[:watch] # FIXME: not implemented yet
    
    # ruhoh.db.urls contains url endpoints as registered by the resources.
    # The urls are mapped to the resource's individual JSGI-compatable Previewer class.
    # Note page-like resources (posts, pages) don't render uniform url endpoints,
    # since presumably they define customized permalinks per singular resource.
    # Page-like resources are handled the root mapping below.
    sorted_urls = ({name: k, url: v} for k, v of ruhoh.db.urls() when ruhoh.resources.exists(k) and k isnt 'base_path')
      .sort (a, b) -> b.url.length - a.url.length

    mappings = for h in sorted_urls
      url: h.url
      prefix:
        if ruhoh.resources.has_previewer h.name
          ruhoh.resources.load_previewer h.name
        else
          collection = ruhoh.resources.load_collection h.name
          try_files = for data in collection.paths().slice().reverse()
            FS.join data.path, collection.namespace()
      app:
        if ruhoh.resources.has_previewer h.name
          ruhoh.resources.load_previewer h.name
        else
          collection = ruhoh.resources.load_collection h.name
          try_files = for data in collection.paths().slice().reverse()
            do ->
              path = FS.join data.path, collection.namespace()
              Apps.Tap(
                Apps.FileTree(path),
                (request) -> # ensure that path exists, Apps.FileTree fails if it doesn't
                  FS.canonical(path).then(
                    -> null,
                    -> Apps.notFound(request)
                  )
              )

          Apps.FirstFound try_files

    console.log mappings

    Apps.Error(
      Apps.Select (request) ->
        for mapping in mappings
          if mapping.url is request.pathInfo.slice(0, mapping.url.length) # starts with
            request.pathInfo = request.pathInfo.slice mapping.url.length
            console.log request.pathInfo
            console.log "match: #{JSON.stringify mapping}"
            console.log mapping.app
            return mapping.app
        return null
        # FIXME
        # The generic Page::Previewer is used to render any/all page-like resources,
        # since they likely have arbitrary urls based on permalink settings.
        # map '/' do :)
        #   run Ruhoh::Base::Pages::Previewer.new(ruhoh) :)
        # end :)
        
    , true)

module.exports.preview = preview
    
if require.main is module
  port = process.argv[2] or 7070
  opts = source: '../pkg/ruhoh.com/' # FIXME: just during development

  preview(opts).then( (app) ->
    HTTP.Server(Apps.Log(app))
    .listen(port)
  ).done()

  console.log "Server running at port: #{port}"  