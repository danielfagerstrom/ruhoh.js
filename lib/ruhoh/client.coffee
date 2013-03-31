_ = require 'underscore'
{puts} = require 'util'
Ruhoh = require '../ruhoh'
friend = require './friend'

class Client
  DefaultBlogScaffold = 'git://github.com/ruhoh/blog.git'
  Help = [
    # {
    #   "command": "new <directory_path>",
    #   "desc": "Create a new blog directory based on the Ruhoh specification."
    # },
    # {
    #   "command": "compile",
    #   "desc": "Compile to static website."
    # },
    {
      "command": "preview [port]",
      "desc": "Preview your website at http://localhost:9292/."
    },
    {
      "command": "help",
      "desc": "Show this menu."
    }
  ]
  constructor: (data) ->
    {@args, @options, @opt_parser} = data
    @ruhoh = new Ruhoh()

    cmd = if @args[0] == 'new' then 'blog' else (@args[0] || 'help')

    return @[cmd]() if @[cmd]?

    @ruhoh.setup_all().then( =>

      unless @ruhoh.resources[cmd]?
        friend.say -> @red "Resource #{cmd} not found"
        process.exit 1
    
      puts "loading client: #{cmd}"
      client = @ruhoh.resources.load_client(cmd, data)
      subCmd = @args[1]
  
      unless client[subCmd]?
        friend.say -> @red "method '#{subCmd}' not found for #{client.constructor.name}"
        process.exit 1
  
      client[subCmd]()
    ).done()

  console: ->
    console_methods = require './console_methods'
    console_methods.env = @args[1]
    _.extend root, console_methods # make console_methods available as globals
    root.init().then =>
      # see http://stackoverflow.com/a/12813186
      require 'coffee-script/lib/coffee-script/repl'

  c: -> console()

  # Show Client Utility help documentation.
  help: ->
    # FIXME: help shouldn't need a full setup, but currently things are initialized in
    # a non optimal way.
    @ruhoh.setup_all().done =>
      options = @opt_parser.helpInformation()
      resources = [{"methods": Help}]
      resources.concat _.compact(for name in @ruhoh.resources.all()
        continue unless @ruhoh.resources.has_client(name)
        continue unless @ruhoh.resources.client(name).Help
        {
          "name": name,
          "methods": @ruhoh.resources.client(name).Help
        }
      )
      
      friend.say ->
        @plain ''
        @plain "  Ruhoh is a nifty, modular static blog generator."
        @plain "  It is the Universal Static Blog API."
        @plain "  Visit http://www.ruhoh.com for complete usage and documentation."
        @plain ''
        @plain options
        @plain '  Commands:'
        @plain ''
        for resource in resources
          for method in resource["methods"]
            if resource["name"]
              @green("    " + "#{resource['name']} #{method['command']}")
            else
              @green("    " + method['command'])
            @plain("      " + method['desc'])
        @plain ''

  # Public: Preview your website.
  preview: ->
    HTTP = require 'q-io/http'
    Apps = require 'q-io/http-apps'
    {preview} = require './programs/preview'

    port = @args[1] or 9292

    preview().then( (app) ->
      HTTP.Server(Apps.Log(app))
      .listen(port)
    ).done()

    puts "Server running at port: #{port}"

  ###
  # Public: Compile to static website.
  compile: ->
    puts Benchmark.measure ->
      Ruhoh::Program.compile(@args[1])
  
  # Public: Create a new blog at the directory provided.
  blog: ->
    name = @args[1]
    scaffold = if @args.length > 2 then @args[2] else DefaultBlogScaffold
    useHg = @options.hg
    unless name
      friend.say ->
        @red "Please specify a directory path." 
        @plain "  ex: ruhoh new the-blogist"
        process.exit 1

    target_directory = File.join(Dir.pwd, name)

    if File.exist?(target_directory)
      friend.say ->
        @red "#{target_directory} already exists."
        @plain "  Specify another directory or `rm -rf` this directory first."
        process.exit 1
    
    friend.say ->
      @plain "Trying this command:"

      if useHg
        @cyan "  hg clone #{scaffold} #{target_directory}"
        success = system('hg', 'clone', scaffold, target_directory)
      else
        @cyan "  git clone #{scaffold} #{target_directory}"
        success = system('git', 'clone', scaffold, target_directory)

      if success
        @green "Success! Now do..."
        @cyan "  cd #{target_directory}"
        @cyan "  rackup -p9292"
        @cyan "  http://localhost:9292"
      else
        @red "Could not git clone blog scaffold. Please try it manually:"
        @cyan "  git clone git://github.com/ruhoh/blog.git #{target_directory}"
  
  ask: (message, valid_options) ->
    if valid_options
      while !valid_options.include?(answer)
        answer = @get_stdin("#{message} #{valid_options.to_s.replace(/\"/g, '').replace(/, /g,'/')} ") 
    else
      answer = @get_stdin(message)
    answer

  get_stdin: (message) ->
    print message
    STDIN.gets.chomp
  ###

module.exports = Client
