define [
  "jquery"
  "underscore"
], ($, _) ->

  Urls =  
    # My Post Title ===> my-post-title
    to_slug: (title) ->
      title = $.trim(title.toLowerCase()).replace(/[\W+]/g, '-') # FIXME: /[^\p{Word}+]/u in original
      title.replace(/^\-+/, '').replace(/\-+$/, '').replace(/\-+/, '-')
    
    to_url_slug: (title) ->
      encodeURIComponent Urls.to_slug(title)
    
    # Ruhoh.config.base_path is assumed to be well-formed.
    # Always remove trailing slash.
    # Returns String - normalized url with prepended base_path
    to_url: (args...) ->
      url = _.compact(args.join("/").split("/")).join "/"
      url = @Ruhoh.config.get('base_path') + url
    
    generate: ->
      Ruhoh = @Ruhoh
      urls                      = {}
      urls.media                = Urls.to_url(Ruhoh.names.assets, Ruhoh.names.media)
      urls.widgets              = Urls.to_url(Ruhoh.names.assets, Ruhoh.names.widgets)
      urls.dashboard            = Urls.to_url(Ruhoh.names.dashboard_file.split('.')[0])

      urls.theme                = Urls.to_url(Ruhoh.names.assets, Ruhoh.config.theme)
      urls.theme_media          = Urls.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.media)
      urls.theme_javascripts    = Urls.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.javascripts)
      urls.theme_stylesheets    = Urls.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.stylesheets)
      urls.theme_widgets        = Urls.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.widgets)
      urls

  Urls
  