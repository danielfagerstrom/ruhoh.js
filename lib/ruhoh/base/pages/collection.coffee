BaseCollection = require '../collection'

class Collection extends BaseCollection
  resource_name: 'pages'
  
  config: ->
    hash = super()
    hash['permalink'] ||= "/:path/:filename"
    hash['summary_lines'] ||= 20
    hash['summary_lines'] = parseInt hash['summary_lines'], 10
    hash['latest'] ||= 2
    hash['latest'] = parseInt hash['latest'], 10
    hash['rss_limit'] ||= 20
    hash['rss_limit'] = parseInt hash['rss_limit'], 10
    hash['ext'] ||= ".md"
    
    paginator = hash['paginator'] || {}
    paginator["namespace"] ||=  "/index"
    unless paginator["namespace"][0] == '/'
      paginator["namespace"] = "/#{paginator['namespace']}"
    unless paginator["namespace"] == '/'
      paginator["namespace"] = paginator["namespace"].replace(/\/$/, '')

    paginator["per_page"] ||=  5
    paginator["per_page"] = parseInt paginator["per_page"], 10
    paginator["layout"] ||=  "paginator"

    if paginator["root_page"]
      unless paginator["root_page"].startsWith('/')
        paginator["root_page"] = "/#{paginator['root_page']}"
      unless paginator["root_page"] == '/'
        paginator["root_page"] = paginator["root_page"].replace(/\/$/, '')

    hash['paginator'] = paginator

    hash

module.exports = Collection
