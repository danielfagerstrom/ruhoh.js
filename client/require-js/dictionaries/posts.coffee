define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/parse"
  "cs!utils/log"
  "cs!urls"
  "libs/moment"
  "yaml"
], ($, _, Backbone, Parse, Log, Urls) ->

  Ruhoh = @Ruhoh

  DateMatcher = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
  Matcher = /^(.+\/)*(.*)(\.[^.]+)$/

  # Posts Dictionary is a hash representation of all posts in the app.
  # This is used as the primary posts database for the application.
  # A post is referenced by its unique url attribute.
  # When working with posts you only need to reference its url identifier.
  # Valid id nodes are expanded to the full post object via the dictionary.
  Backbone.Model.extend

    generate2: ->
      Ruhoh.ensure_setup
        
      @process()
      .pipe((results) =>
        ordered_posts = @ordered_posts(results['posts'])
        {
          dictionary:      results['posts'],
          drafts:          results['drafts'],
          # chronological:   @build_chronology(ordered_posts),
          # collated:        @collate(ordered_posts),
          # tags:            @parse_tags(ordered_posts),
          # categories:      @parse_categories(ordered_posts)
        }
      )

    process: ->
      dictionary = {}
      drafts = []
      invalid = []

      @files().pipe((filenames) =>
        readFiles = for filename in filenames
          do (filename) ->
            $.get(filename)
            .pipe (content) ->
              {filename, content}
          
        $.when(readFiles...)
        .pipe((results...) =>
          for {filename, content} in results
            data = Parse.frontMatter(content, filename)
              
            filename_data = @parse_page_filename(filename)
            unless filename_data
              error = "Invalid Filename Format. Format should be: my-post-title.ext"
              invalid.push [filename, error]
              continue
            
            data['date'] ||= filename_data['date']

            unless @formatted_date(data['date'])
              error = "Invalid Date Format. Date should be: YYYY-MM-DD"
              invalid.push [filename, error]
              continue

            if data['type'] == 'draft'
              next if Ruhoh.config.env == 'production'
              drafts.push filename 
            
            data['date']          = data['date']
            data['id']            = filename
            data['title']         = data['title'] || filename_data['title']
            data['url']           = @permalink(data)
            data['layout']        = Ruhoh.config.posts_layout if data['layout'].nil?
            dictionary[filename]  = data
          #Ruhoh::Utils.report('Posts', dictionary, invalid)
          
          { 
            posts: dictionary
            drafts: drafts
          }
        )        
      )

    parse_date: (date) ->
      moment date, "YYYY-MM-DD"

    formatted_date: (date) ->
      try
        date = @parse_date date
        date.format "YYYY-MM-DD"
      catch e
        false
      
    files: ->
      $.get("?pattern=#{Ruhoh.paths.posts}/**/*.*")
      .pipe((files) =>
        _.filter files, @is_valid_page
      )

    is_valid_page: (filepath) ->
      return false if filepath[filepath.length - 1] is '/'
      return false if filepath[0] is '.'
      for regex in Ruhoh.config.get('posts_exclude')
        return false if regex.test filepath
      true

    ordered_posts: (dictionary) ->
      _.sortBy (val for key, val of dictionary), (data) =>
        @parse_date(data.date)
      
    parse_page_filename: (filename) ->
      data = filename.match(DateMatcher)
      data = filename.match(Matcher) unless data
      return {} unless data

      if DateMatcher.test(filename)
        path: data[1],
        date: data[2],
        slug: data[3],
        title: @to_title(data[3]),
        extension: data[4]
      else
        path: data[1],
        slug: data[2],
        title: @to_title(data[2]),
        extension: data[3]

    # my-post-title ===> My Post Title
    to_title: (file_slug) ->
      file_slug.replace(/[^\w+]/g, ' ').replace(/\b\w/g, (c) -> c.toUpperCase())
      
    # Used in the client implementation to turn a draft into a post.  
    to_filename: (data) ->
      @config.fileJoin(Ruhoh.paths.posts, "#{Urls.to_slug(data['title'])}.#{data['ext']}")
    
    # Another blatently stolen method from Jekyll
    # The category is only the first one if multiple categories exist.
    permalink: (post) ->
      date = @parse_date(post['date'])
      title = Urls.to_url_slug(post['title'])
      format = post['permalink'] || Ruhoh.config.get('posts_permalink')

      if format.indexOf(':') isnt -1
        # basename w.o. extension
        filename = (p = post.id.split('/'))[p.length - 1].replace(/\.[^.]+$/,'')
        category = post.categories?[0]
        category = (Urls.to_url_slug(c) for c in category.split('/')).join('/') if category
      
        for pattern, value of {
          year:       date.format('YYYY')
          month:      date.format('MM')
          day:        date.format('DD')
          title:      title
          filename:   filename
          i_day:      date.format('D')
          i_month:    date.format('M')
          categories: category || '',
        }
          format = format.replace new RegExp(':' + pattern), value
        url = format.replace(/\/+/g, "/")
      else
        # Use the literal permalink if it is a non-tokenized string.
        url = (encodeURIComponent(p) for p in format.replace(/^\//, '').split('/')).join('/')

      Urls.to_url(url)
    
    # stupid javascript Dates.
    Months: ["January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December"
    ]
    
    generate: ->
      @fetch dataType: "html", cache: false

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
