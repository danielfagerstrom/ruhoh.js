define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/parse"
  "cs!utils/log"
  "yaml"
], ($, _, Backbone, Parse, Log) ->
  
  # Posts Dictionary is a hash representation of all posts in the app.
  # This is used as the primary posts database for the application.
  # A post is referenced by its unique url attribute.
  # When working with posts you only need to reference its url identifier.
  # Valid id nodes are expanded to the full post object via the dictionary.
  Backbone.Model.extend
    
    # stupid javascript Dates.
    Months: ["January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December"
    ]
    
    initialize: (attrs) ->

    generate: ->
      @fetch
        dataType: "html"
        cache: false

    url: ->
      @config.getDataPath "/database/posts_dictionary.yml"

    parse: (response) ->
      data = jsyaml.load(response) or {}
      # Need to append the posts id to urls for client-side rendering.
      # i.e. We need to tell javascript where the file is.
      for id of data["dictionary"]
        data["dictionary"][id]["url"] += ("?path=" + @config.fileJoin(@config.get("postsDirectory"), id))
      @set data
      @attributes
    
    # TODO: Need to optimize the post sorting for when post quantity gets unwieldy.
    # Sets a sorted Array containing Objects.
    buildChronology: ->
      # Order by date descending
      @set "chronoHash", _.sortBy(@get("dictionary"), (post) ->
        new Date(post.date)
      ).reverse()
      
      # Standardize this as a simple Array since pages operate in this way.
      # Sets a sorted Array containing Objects.
      @set "chronological", _.map(@get("chronoHash"), (post) ->
        post.id
      )
    
    # Create a collated posts data structure.
    # [{ 'year': year,
    #   'months' : [{ 'month' : month,
    #      'posts': [{}, {}, ..] }, ..] }, ..]
    #
    collate: ->
      collated = []
      _.each @get("chronoHash"), ((post, i, posts) ->
        thisDate = new Date(post.date)
        thisYear = thisDate.getFullYear().toString()
        thisMonth = @Months[thisDate.getMonth()]
        prevDate = undefined
        prevMonth = undefined
        prevYear = undefined
        if posts[i - 1]
          prevDate = new Date(posts[i - 1].date)
          prevYear = prevDate.getFullYear().toString()
          prevMonth = @Months[prevDate.getMonth()]
        if prevYear and prevYear is thisYear
          if prevMonth and prevMonth is thisMonth
            collated[collated.length - 1].months[collated.months.length - 1].posts.push post # append to last year & month
          else
            collated[collated.length - 1].months.push
              month: thisMonth
              posts: new Array(post)

        # create new month
        else
          collated.push
            year: thisYear
            months: [
              month: thisMonth
              posts: new Array(post)
            ]

      # create new year & month
      ), this
      @set "collated", collated

    # Create the TagsDictionary
    parseTags: ->
      tags = {}
      _.each @get("dictionary"), (post) ->
        _.each post.tags, (tag) ->
          if tags.hasOwnProperty(tag)
            tags[tag].count += 1
          else
            tags[tag] =
              count: 1
              name: tag
              posts: []
          tags[tag].posts.push post.url

      @tagsDictionary = tags
