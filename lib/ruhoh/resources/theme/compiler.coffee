_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
glob = require 'glob'
BaseCompiler = require '../../base/compiler'
friend = require '../../friend'
utils = require '../../utils'

class Compiler extends BaseCompiler

  run: ->
    @copy()

  # Copies all assets over to the compiled site.
  # Note the compiled assets are namespaced at /assets/
  copy: ->
    collection = @collection
    @collection.hasPaths().then (has_paths) =>
      unless true or has_paths
        friend.say ->
          @yellow "#{utils.capitalize collection.namespace()}: directory not found - skipping."
        return

      friend.say ->
        @cyan "Theme: ('#{utils.capitalize collection.namespace()}' copying non-resource files)"

      theme = utils.url_to_path(@ruhoh.db.urls()["theme"], @ruhoh.paths.compiled)
      FS.makeTree(theme).then( =>
        @files()
      ).then (files) =>
        Q.all(
          for file in files
            do (file) =>
              original_file = FS.join(@ruhoh.paths.theme, file)
              compiled_file = FS.join(theme, file)
              FS.makeTree(FS.directory compiled_file).then( =>
                FS.copyTree original_file, compiled_file
              ).then ->
                friend.say -> @green "  > #{file}"
        )

  # Returns list of all files from the theme to be compiled.
  # @returns[Array] relative filepaths
  files: ->
    Q.nfcall(glob, "**/*", cwd: @ruhoh.paths.theme, mark: true).then (filepaths) =>
      (filepath for filepath in filepaths when @is_valid_asset filepath)

  # Checks a given asset filepath against any user-defined exclusion rules in theme.yml
  # Omit layouts, stylesheets, javascripts, media as they are handled by their respective resources.
  # @returns[Boolean]
  is_valid_asset: (filepath) ->
    return false if filepath.match /\/$/
    return false if _.some(['.', 'layouts', 'stylesheets', 'javascripts', 'media'], (prefix) -> filepath.indexOf(prefix) == 0)
    toArray = (array) -> if _.isArray(array) then array else if array? [array] else []
    excludes = (new RegExp node for node in toArray(@collection.config()['exclude']))
    for regexp in excludes
      return false if filepath.match regexp
    true

module.exports = Compiler
