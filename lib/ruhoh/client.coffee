_ = require 'underscore'
Ruhoh = require '../ruhoh'
friend = require './friend'
console_methods = require './console_methods'

class Client
  Help = [
    {
      "command": "new <directory_path>",
      "desc": "Create a new blog directory based on the Ruhoh specification."
    },
    {
      "command": "compile",
      "desc": "Compile to static website."
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

    unless @ruhoh.resources[cmd]?
      friend.say "Resource #{cmd} not found".red
      process.exit 1
    
    @ruhoh.setup_all().then( =>
      client = new (@ruhoh.resources.client(cmd))(@ruhoh, data)
  
      unless client[@args[1]]?
        friend.say "method '#{@args[1]}' not found for #{client.constructor.name}".red
        process.exit 1
  
      client[@args[1]]()
    ).done()

  # FIXME: just for simplifying testing
  setup: ->
    OPTS =
      source: '../pkg/ruhoh.com/'
    @ruhoh.setup_all(OPTS).done()

  console: ->
    console_methods.env = @args[1]
    _.extend root, console_methods # make console_methods available as globals
    root.init().then =>
      # see http://stackoverflow.com/a/12813186
      require 'coffee-script/lib/coffee-script/repl'
      

module.exports = Client

if require.main is module
  new Client args: process.argv[2...]