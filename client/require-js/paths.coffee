define [
  "underscore"
  "cs!utils/log"
], (_, Log) ->

  Ruhoh = @Ruhoh

  # Like ruby B)
  fileJoin = (args...) ->
    return ""  if args.length is 0
    _.compact(args.join("/").split("/")).join "/"
  
  theme_is_valid = (paths) ->
    return true if true # FIXME: FileTest.directory?(paths.theme)
    Log.configError("Theme directory does not exist: #{paths.theme}")
    return false
    
  generate: ->
    paths                     = {}
    paths.base                = Ruhoh.base
    paths.config_data         = fileJoin(Ruhoh.base, Ruhoh.names.config_data)
    paths.pages               = fileJoin(Ruhoh.base, Ruhoh.names.pages)
    paths.posts               = fileJoin(Ruhoh.base, Ruhoh.names.posts)
    paths.partials            = fileJoin(Ruhoh.base, Ruhoh.names.partials)
    paths.media               = fileJoin(Ruhoh.base, Ruhoh.names.media)
    paths.widgets             = fileJoin(Ruhoh.base, Ruhoh.names.widgets)
    paths.compiled            = fileJoin(Ruhoh.base, Ruhoh.names.compiled)
    paths.dashboard_file      = fileJoin(Ruhoh.base, Ruhoh.names.dashboard_file)
    paths.site_data           = fileJoin(Ruhoh.base, Ruhoh.names.site_data)
    paths.themes              = fileJoin(Ruhoh.base, Ruhoh.names.themes)
    paths.plugins             = fileJoin(Ruhoh.base, Ruhoh.names.plugins)
    paths.scaffolds           = fileJoin(Ruhoh.base, Ruhoh.names.scaffolds)
    
    paths.theme               = fileJoin(Ruhoh.base, Ruhoh.names.themes, Ruhoh.config.theme)
    paths.theme_dashboard_file= fileJoin(paths.theme, Ruhoh.names.dashboard_file)
    paths.theme_config_data   = fileJoin(paths.theme, Ruhoh.names.theme_config)
    paths.theme_layouts       = fileJoin(paths.theme, Ruhoh.names.layouts)
    paths.theme_stylesheets   = fileJoin(paths.theme, Ruhoh.names.stylesheets)
    paths.theme_javascripts   = fileJoin(paths.theme, Ruhoh.names.javascripts)
    paths.theme_media         = fileJoin(paths.theme, Ruhoh.names.media)
    paths.theme_widgets       = fileJoin(paths.theme, Ruhoh.names.widgets)
    paths.theme_partials      = fileJoin(paths.theme, Ruhoh.names.partials)
    
    return false unless theme_is_valid(paths)
    
    paths.system                    = fileJoin(Ruhoh.Root, Ruhoh.names.system)
    paths.system_dashboard_file     = fileJoin(paths.system, Ruhoh.names.dashboard_file)
    paths.system_partials           = fileJoin(paths.system, Ruhoh.names.partials)
    paths.system_scaffolds          = fileJoin(paths.system, Ruhoh.names.scaffolds)
    paths.system_widgets            = fileJoin(paths.system, Ruhoh.names.widgets)

    paths
