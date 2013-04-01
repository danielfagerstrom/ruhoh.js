_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
BaseCompiler = require '../compiler'
friend = require '../../friend'
utils = require '../../utils'
Mustache = require '../../views/rmustache'

class Compiler extends BaseCompiler
  run: ->
    resource_name = @resource_name()
    @ruhoh.db[resource_name]().then (pages) =>
      friend.say -> @cyan "#{utils.capitalize resource_name}: (#{_.size pages} #{resource_name})"

      Q.all (
        for id, data of pages
          do (data) =>
            view = @ruhoh.master_view(data['pointer'])

            view.compiled_path().then (compiled_path) =>
              path = FS.join @ruhoh.paths.compiled, compiled_path
              FS.makeTree(FS.directory path).then( ->
                view.render_full()
              ).then( (rendered) ->
                FS.write(path, rendered)
              ).then ->
                friend.say -> @green "  > #{data['id']}"
      ).concat [
        @pagination()
        @rss()
      ]

  pagination: ->
    resource_name = @resource_name()
    config = @ruhoh.db.config(resource_name)["paginator"] || {}
    if config["enable"] == false
      friend.say -> @yellow "#{resource_name} paginator: disabled - skipping."
      return

    @ruhoh.resources.load_collection_view(resource_name).all().then (pages) =>
      pages_count = pages.length
      total_pages = Math.ceil(pages_count/config["per_page"])

      friend.say -> @cyan "#{resource_name} paginator: (#{total_pages} pages)"
      
      Q.all (
        for i in [0...total_pages]
          # if a root page is defined we assume it's getting compiled elsewhere.
          continue if (i == 0 && config["root_page"])

          do (i) =>
            url = "#{config['namespace']}/#{i+1}"
            view = @ruhoh.master_view({"resource": resource_name})
            view.page_data = {
              "layout": config["layout"],
              "current_page": (i+1),
              "url": @ruhoh.to_url(url)
            }
            view.compiled_path().then (compiled_path) =>
              path = FS.join @ruhoh.paths.compiled, compiled_path
              FS.makeTree(FS.directory path).then( ->
                view.render_full()
              ).then( (rendered) ->
                FS.write(path, rendered)
              ).then ->
                friend.say -> @green "  > #{view.page_data['url']}"
      )

  rss: ->
    resource_name = @resource_name()
    config = @ruhoh.db.config(resource_name)["rss"] || {}
    if config["enable"] == false
      friend.say -> @yellow "#{resource_name} RSS: disabled - skipping."
      return

    limit = config["limit"] || 20
    collection_view = @ruhoh.resources.load_collection_view(resource_name)
    collection_view.all().then (pages) =>
      # FIXME: sort?
      pages = pages[0...limit]
      friend.say -> @cyan "#{resource_name} RSS: (first #{limit} pages)"

      context =
        title: @ruhoh.db.data().get('title')
        production_url: @ruhoh.config()['production_url']
        date: (new Date()).toUTCString()
        pages: (
          for page in pages
            view = @ruhoh.master_view(page.pointer)
            title: page.title
            url:  page.url
            date: (new Date(page.date)).toUTCString() if page.date
            description: if page.description then page.description else view.render_content()
        )
      
      Q.when Mustache.render(rssTemplate, context), (feed) =>
        
        compiled_path =
          decodeURIComponent(@ruhoh.to_url(@ruhoh.paths.compiled, @collection.namespace(), "rss.xml"))
        compiled_path = compiled_path.replace(/^\//, '')

        FS.makeTree(FS.directory(compiled_path)).then( ->
          FS.write(compiled_path, feed)
        ).then ->
          friend.say -> @green "  > #{compiled_path}"

rssTemplate = '''
<?xml version=\"1.0\"?>
<rss version="2.0">
  <channel>
    <title>{{title}}</title>
    <link>{{{production_url}}}</link>
    <pubDate>{{date}}</pubDate>
    {{#pages}}
    <item>
      <title>{{title}}</title>
      <link>{{{production_url}}}{{{url}}}</link>
      {{#date}}<pubDate>{{{.}}}</pubDate>{{/date}}
      <description>
        {{{description}}}
      </description>
    </item>
    {{/pages}}
  </channel>
</rss>
'''

module.exports = Compiler
