Q = require 'q'
FS = require 'q-io/fs'
BaseCompiler = require '../../base/compiler'
friend = require '../../friend'
utils = require '../../utils'

class Compiler extends BaseCompiler
  run: ->
    collection = @collection
    @collection.hasPaths().then (has_paths) =>
      unless has_paths
        friend.say ->
          @yellow "#{utils.capitalize collection.namespace()}: directory not found - skipping."
        return
      friend.say -> @cyan "#{utils.capitalize collection.namespace()}: (copying valid files)"

      compiled_path = utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint()), @ruhoh.paths.compiled)
      FS.makeTree(compiled_path).then( =>
        @collection.files()
      ).then (files) =>
        Q.all(
          for pointer in files
            do (pointer) =>
              compiled_file = FS.join(compiled_path, pointer['id'])
              FS.makeTree(FS.directory compiled_file).then( =>
                FS.copyTree(pointer['realpath'], compiled_file)
              ).then =>
                friend.say -> @green "  > #{pointer['id']}"
        )

module.exports = Compiler
