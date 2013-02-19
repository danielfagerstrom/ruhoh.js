path = require 'path'
Q = require 'q'
glob = require 'glob'
logger = require './ruhoh/logger'
utils = require './ruhoh/utils'
friend = require './ruhoh/friend'
ResourcesInterface = require './ruhoh/resources_interface'
DB = require './ruhoh/db'

Root = path.join __dirname, '..'
class Ruhoh
  @log = logger
  @root = Root

  constructor: ->
    @resources = new ResourcesInterface(this)
    @db = new DB(this)

  master_view: (pointer) ->
    throw new Error 'not implemented'
    new Ruhoh.Views.MasterView(self, pointer)

  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  setup: (opts={}) ->
    @reset()
    # @constructor.log.log_file = opts.log_file if opts.log_file #todo
    @base = opts.source if opts.source
    @_load_config().then (config) -> !!config
  
  reset: ->
    @base = process.cwd()
  
  _load_config: ->
    utils.parse_yaml_file(@base, "config.yml").then (config) =>
      config['compiled'] = if config['compiled'] then path.resolve(config['compiled'], process.cwd()) else "compiled"

      config['base_path'] = config['base_path']?.strip()
      unless config['base_path']
        config['base_path'] = '/'
      else
        config['base_path'] += "/" unless config['base_path'][config['base_path'].length-1] == '/'
      
      @_config = config
  
  config: ->
    @ensure_config()
    @_config

  setup_paths: ->
    @ensure_config()
    @paths =
      base: @base
      system: path.join(Root, "system")
      compiled: @config()["compiled"]
    if false and theme = @db.config('theme')['name'] # FIXME
      friend.say "Using theme: \"#{theme}\""
      @path.theme = path.join(@base, theme)

    @paths

  # Not part of ruhoh.rb
  setup_resources: ->
    @ensure_paths()
    @resources.setup()

  # Not part of ruhoh.rb
  setup_db: ->
    @ensure_paths()
    @db.setup()

  setup_plugins: -> # FIXME: add sprockets
    @ensure_paths()
    Q.nfcall(glob, path.join(@base, "plugins", "**/*.js")).then (plugins) =>
      if plugins.length
        for f in plugins
          require f

  setup_all: (opts={}) ->
    @setup(opts)
    .then( =>
      @setup_paths()
      @setup_resources()
    ).then =>
      @setup_db()
      @setup_plugins() if opts.enable_plugins

  env: ->
    @_env || 'development'
  
  base_path: ->
    if @env() == 'production'
      @config()['base_path']
    else
      '/'

  # @config['base_path'] is assumed to be well-formed.
  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  to_url: (args...) ->
    url = @base_path() + args.join('/')
    url = url.replace(/\/\//, '/')
    if url == "/" then url else url.replace(/\/$/, '')
  
  relative_path: (filename) ->
    filename.replace(new RegExp("^#{@base}/"), '')

  # Compile the ruhoh instance (save to disk).
  # Note: This method recursively removes the target directory. Should there be a warning?
  #
  # Extending:
  #   TODO: Deprecate this functionality and come up with a 2.0-friendly interface.
  #   The Compiler module is a namespace for all compile "tasks".
  #   A "task" is a ruby Class that accepts @ruhoh instance via initialize.
  #   At compile time all classes in the Ruhoh::Compiler namespace are initialized and run.
  #   To add your own compile task simply namespace a class under Ruhoh::Compiler
  #   and provide initialize and run methods:
  #
  #  class Ruhoh
  #    module Compiler
  #      class CustomTask
  #        def initialize(ruhoh)
  #          @ruhoh = ruhoh
  #        end
  #       
  #        def run
  #          # do something here
  #        end
  #      end
  #    end
  #  end

  compile: ->
    throw new Error 'not implemented'
    @ensure_paths()
    friend.say "Compiling for environment: '#{@env()}'"
    FileUtils.rm_r @paths.compiled if File.exist?(@paths.compiled)
    FileUtils.mkdir_p @paths.compiled
    
    # Run the resource compilers
    for name of @resources.all
      continue unless @resources.compiler?(name)
      @resources.load_compiler(name).run()
    
    # Run extra compiler tasks if available:
    if Ruhoh.const_defined?('Compiler')
      for c in Ruhoh.Compiler.constants
        compiler = Ruhoh.Compiler.const_get(c)
        continue unless compiler.respond_to?('new')
        task = new compiler(this)
        continue unless task.respond_to?('run')
        task.run()
    true
  
  ensure_setup: ->
    return if @_config and @paths
    throw new Error('Ruhoh has not been fully setup. Please call: Ruhoh.setup')
  
  ensure_config: ->
    return if @_config
    throw new Error('Ruhoh has not setup config. Please call: Ruhoh.setup')

  ensure_paths: ->
    return if @_config and @paths
    throw new Error('Ruhoh has not setup paths. Please call: Ruhoh.setup')

module.exports = Ruhoh
