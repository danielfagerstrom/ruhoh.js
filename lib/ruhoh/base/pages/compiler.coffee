_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
BaseCompiler = require '../compiler'
friend = require '../../friend'
utils = require '../../utils'

class Compiler extends BaseCompiler
  run: ->
    resource_name = @resource_name()
    @ruhoh.db[resource_name]().then (pages) =>
      friend.say -> @cyan "#{utils.capitalize resource_name}: (#{_.size pages} #{resource_name})"
      Q.all(
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
      )
      # @pagination()
      # @rss()

  ###
  pagination: ->
    config = @ruhoh.db.config(resource_name)["paginator"] || {}
    resource_name = self.resource_name
    if config["enable"] == false
      Ruhoh::Friend.say { yellow "#{resource_name} paginator: disabled - skipping." }
      return

    pages_count = @ruhoh.resources.load_collection_view(resource_name).all.length
    total_pages = (pages_count.to_f/config["per_page"]).ceil

    Ruhoh::Friend.say { cyan "#{resource_name} paginator: (#{total_pages} pages)" }
    
    FileUtils.cd(@ruhoh.paths.compiled) {
      total_pages.times.map { |i| 
        # if a root page is defined we assume it's getting compiled elsewhere.
        next if (i.zero? && config["root_page"])

        url = "#{config["namespace"]}/#{i+1}"
        view = @ruhoh.master_view({"resource" => resource_name})
        view.page_data = {
          "layout" => config["layout"],
          "current_page" => (i+1),
          "url" => @ruhoh.to_url(url)
        }
        FileUtils.mkdir_p File.dirname(view.compiled_path)
        File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }
        Ruhoh::Friend.say { green "  > #{view.page_data['url']}" }
      }
    }

  rss: ->
    config = @ruhoh.db.config(resource_name)["rss"] || {}
    resource_name = self.resource_name
    if config["enable"] == false
      Ruhoh::Friend.say { yellow "#{resource_name} RSS: disabled - skipping." }
      return

    limit = config["limit"] || 20
    collection_view = @ruhoh.resources.load_collection_view(resource_name)
    pages = collection_view.all.first(limit)
    Ruhoh::Friend.say { cyan "#{resource_name} RSS: (first #{limit} pages)" }
    
    feed = Nokogiri::XML::Builder.new do |xml|
     xml.rss(:version => '2.0') {
       xml.channel {
         xml.title_ @ruhoh.db.data['title']
         xml.link_ @ruhoh.config['production_url']
         xml.pubDate_ Time.now          
         pages.each do |page|
           view = @ruhoh.master_view(page.pointer)
           xml.item {
             xml.title_ page.title
             xml.link "#{@ruhoh.config['production_url']}#{page.url}"
             xml.pubDate_ page.date if page.date
             xml.description_ (page.description ? page.description : view.render_content)
           }
       }
     }

    FileUtils.cd(@ruhoh.paths.compiled) {
      compiled_path = CGI.unescape(@ruhoh.to_url(@collection.namespace, "rss.xml"))
      compiled_path = compiled_path.gsub(/^\//, '')

      FileUtils.mkdir_p File.dirname(compiled_path)
      File.open(compiled_path, 'w'){ |p| p.puts feed.to_xml }

      Ruhoh::Friend.say { green "  > #{compiled_path}" }
    }
  ###

module.exports = Compiler
