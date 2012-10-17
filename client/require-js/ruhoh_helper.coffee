define [
  "jquery"
  "underscore"
], ($, _) ->
  
  # parse the mustache expression's name
  parseContext: (tagName) ->
    tagName.split("?")[0] or null

  # Query based on helper name
  # Helpers must start with "?"
  # If we can't find anything it's important to return undefined.
  query: (name, context, stack) ->
    helper = name.split("?")[1]
    this[helper] context, stack  if helper and typeof this[helper] is "function"

  to_pages: (context, stack) ->
    pages = []
    if _.isArray(context)
      _.each context, (id) ->
        pages.push stack.pages[id]  if stack.pages[id]
    else
      pages = stack.pages
    _.map pages, (page) ->
      page.isActivePage = true  if stack.page.id is page.id
      page

  to_tags: (context, stack) ->
    (if _.isArray(context) then _.map(context, (name) ->
      stack.posts.tags[name]  if stack.posts.tags[name]
    ) else _.map(stack.posts.tags, (tag) ->
      tag
    ))

  to_posts: (context, stack) ->
    _.map (if _.isArray(context) then context else stack.posts.chronological), (id) ->
      stack.posts.dictionary[id]  if stack.posts.dictionary[id]

  to_categories: (context, stack) ->
    (if _.isArray(context) then _.map(context, (name) ->
      stack.posts.categories[name]  if stack.posts.categories[name]
    ) else _.map(stack.posts.categories, (cat) ->
      cat
    ))
  
  # Probably not going to use this since its simple enough to
  # call the data structure directly.
  posts_collate: (context, stack) ->
    stack.posts.collated

