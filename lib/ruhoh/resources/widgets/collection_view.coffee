_ = require 'underscore'
Q = require 'q'

BaseCollectionView = require '../../base/collection_view'

class CollectionView extends BaseCollectionView

  constructor: (collection) ->
    super(collection)
    @setup_promise = @collection.widgets().then (widgets) =>
      for widget in widgets
        @[widget] = => @widget widget
      this

  widget: (name) ->
    Q.all([
      Q.when(@master.page_data)
      @ruhoh.db.widgets()
    ]).spread (page_data, widgets) =>
      page_config = page_data["widgets"]?[name] || {}
      config = _.extend {}, (@ruhoh.db.config('widgets')[name] || {}), page_config
      return '' if config['enable'] == 'false'

      pointer = widgets["#{name}/#{(config['use'] || 'default')}.html"]?['pointer']
      return '' unless pointer

      Q.all([
        @ruhoh.db.update(pointer)
        @ruhoh.db.content(pointer)
      ]).spread (data, content) =>
        view = @ruhoh.master_view('')

        # merge the config.yml data into the inline layout data.
        # Note this is reversing the normal hierarchy 
        # in that inline should always override config level.
        # However the inline in this case is set as implementation defaults 
        # and meant to be overridden by user specific data.
        view.render(content, {
          "this_config": _.extend {}, data, config
          "this_path": @ruhoh.to_url(@collection.url_endpoint(), name)
        })

module.exports = CollectionView
