Q = require 'q'
BaseModelView = require '../model_view'
utils = require '../../utils'
converter = require '../../converter'

class ModelView extends BaseModelView

  # Default order by alphabetical title name.
  compare: (other) ->
    sort = @ruhoh.db.config(@collection.resource_name())["sort"] || []
    attribute = sort[0] || "title"
    direction = sort[1] || "asc"

    this_data = @[attribute]
    other_data = other[attribute]
    if attribute == "date"
      this_data = this_data.valueOf()
      other_data = other_data.valueOf()
      direction = sort[1] || "desc" #default should be reverse

    if direction == "asc"
      utils.compare this_data, other_data
    else
      utils.compare other_data, this_data

  categories: ->
    @collection.to_categories()(super())

  tags: ->
    @collection.to_tags()(super())

  # Lazy-load the page body.
  # Notes:
  # @_content is not used for caching, it's used to manually
  # define content for a given page. Useful in the case that
  # you want to model a resource that does not actually
  # reference a file.
  content: ->
    return @_content if @_content
    @get_page_content().spread (content, id) =>
      @master.render(content).then (content) =>
        converter.convert(content, id)

  get_page_content: ->
    @ruhoh.db.content(@pointer).then (content) =>
      [content, @id]
  
  is_active_page: ->
    Q.when @master.page_data, (page_data) =>
      @id == page_data['id']
  
  # Truncate the page content relative to a line_count limit.
  # This is optimized for markdown files in which content is largely
  # blocked into chunks and separating by blank lines.
  # The line_limit truncates content based on # of content-based lines,
  # so blank lines don't count toward the limit.
  # Always break the content on a blank line only so result stays formatted nicely.
  summary: ->
    @get_page_content().spread (content, id) =>
      resource = @pointer["resource"]
      line_limit = @ruhoh.db.config(resource)['summary_lines']
      line_count = 0
      lines = content.split /^/
      line_breakpoint = lines.length

      for line, i in lines
        if line.match /^\s*$/  # line with only whitespace
          if line_count >= line_limit
            line_breakpoint = i
            break
        else
          line_count += 1

      summary = lines[0...line_breakpoint].join('')

      # The summary may be missing some key items needed to render properly.
      # So search the rest of the content and add it to the summary.
      for line in lines[line_breakpoint...]
        # Add lines containing destination urls.
        if line.match /^\[[^\]]+\]:/
          summary += "\n#{line}"

      @master.render(summary).then (summary) =>
        converter.convert(summary, id)

  next: ->
    return unless @id
    @collection.all().then (all_cache) =>
      index = (i for p, i in all_cache when p.id is @id)[0] ? -1
      return unless index && (index-1 >= 0)
      _next = all_cache[index-1]
      return unless _next
      _next

  previous: ->
    return unless @id
    @collection.all().then (all_cache) =>
      index = (i for p, i in all_cache when p.id is @id)[0] ? -1
      return unless index && (index+1 >= 0)
      prev = all_cache[index+1]
      return unless prev
      prev

module.exports = ModelView
