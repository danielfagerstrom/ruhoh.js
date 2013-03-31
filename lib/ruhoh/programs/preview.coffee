FS = require 'q-io/fs'
Apps = require 'q-io/http-apps'
{FirstFound} = require 'q-io/http-apps/route'
Ruhoh = require '../../ruhoh'
PagesPreviewer = require '../base/pages/previewer'

# Apps.FileTree fails instead of returning 404 when the root doesn't exist
FileTree = (root, options) ->
  fileTree = null
  (request, response) ->
    FS.canonical(root).then(
      (root) -> (fileTree ?= Apps.FileTree(root, options))(request, response),
      (reason) -> Apps.notFound(request, response)
    )

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
      app:
        if ruhoh.resources.has_previewer h.name
          ruhoh.resources.load_previewer(h.name).call
        else
          collection = ruhoh.resources.load_collection h.name
          try_files = for data in collection.paths().slice().reverse()
            do ->
              path = FS.join data.path, collection.namespace()
              FileTree(path)

          FirstFound try_files

    pagesPreviewer = new PagesPreviewer ruhoh

    Apps.Error(
      Apps.Select (request) ->
        for mapping in mappings
          if mapping.url is request.pathInfo.slice(0, mapping.url.length) # starts with
            request.pathInfo = request.pathInfo.slice mapping.url.length
            return mapping.app

        # The generic Page::Previewer is used to render any/all page-like resources,
        # since they likely have arbitrary urls based on permalink settings.
        pagesPreviewer.call
        
    , true)

module.exports.preview = preview
