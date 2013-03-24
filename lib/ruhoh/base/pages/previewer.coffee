utils = require '../../utils'

# Public: JSGI application used to render singular pages via their URL.

class Previewer

  constructor: (@ruhoh) ->
    @ruhoh = ruhoh

  call: (env) =>
    return @favicon() if env.pathInfo == '/favicon.ico'

    # Always remove trailing slash if sent unless it's the root page.
    env.pathInfo = utils.chomp(env.pathInfo) unless env.pathInfo == "/"

    pointer = @ruhoh.db.routes[env.pathInfo]
    view = if pointer then @ruhoh.master_view(pointer) else @paginator_view(env)

    if view
      status: 200, headers: {'Content-Type': 'text/html'}, body: [view.render_full()]
    else
      throw new Error "Page id not found for url: #{env.pathInfo}"

  # Try the paginator.
  # search for the namespace and match it to a resource:
  # need a way to register pagination namespaces then search the register. 
  paginator_view: (env) ->
    path = env.pathInfo.replace(/^\//, '')
    resource = path.split('/')[0]
    return null unless @ruhoh.resources.exist(resource)

    config = @ruhoh.db.config(resource)["paginator"] || {}
    page_number = path.split('/').pop()

    view = @ruhoh.master_view({"resource": resource})
    view.page_data =
      "layout": config["layout"],
      "current_page": page_number
    view

  favicon: ->
    status: 200, headers: {'Content-Type': 'image/x-icon'}, body: ['']

module.exports = Previewer
