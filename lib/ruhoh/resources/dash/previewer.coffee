
class Previewer
  constructor: (@ruhoh) ->

  call: (env) =>
    @ruhoh.db.dash().then (pointer) =>
      view = @ruhoh.master_view(pointer)
      status: 200, headers: {'Content-Type': 'text/html'}, body: [view.render_full()]

module.exports = Previewer
