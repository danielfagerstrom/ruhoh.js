_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
crypto = require 'crypto'
fs = require 'fs'
BaseCompiler = require '../compiler'
friend = require '../../friend'
utils = require '../../utils'

digestMD5File = (fileName) ->
  deferred = Q.defer()
  md5Sum = crypto.createHash 'md5'
  s = fs.ReadStream fileName
  s.on 'data', (d) ->
    md5Sum.update d
  s.on 'end', ->
    deferred.resolve md5Sum.digest 'hex'
  s.on 'error', (err) ->
    deferred.reject new Error err
  deferred.promise

class Compiler extends BaseCompiler
  # A basic compiler task which copies each valid collection resource file to the compiled folder.
  # Valid files are identified by their pointers.
  # Invalid files are files that are excluded from the resource's configuration settings.
  # The collection's url_endpoint is used to determine the final compiled path.
  #
  # @returns Nothing.
  run: ->
    collection = @collection

    @collection.hasPaths().then (has_paths) =>
      unless has_paths
        friend.say ->
          @yellow "#{utils.capitalize collection.namespace()}: directory not found - skipping."
        return

      friend.say -> @cyan "#{utils.capitalize collection.namespace()}: (copying valid files)"

      compiled_path = utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint()), @ruhoh.paths.compiled)
      manifest = {}
      FS.makeTree(compiled_path).then( =>
        @collection.files()
      ).then (pointers) =>
        Q.all(
          for pointer in pointers
            do (pointer) =>
              digestMD5File(pointer['realpath']).then (digest) =>
                digest_file = pointer['id'].replace(/\.(\w+)$/, (ext) -> "-#{digest}#{ext}")
                manifest[pointer['id']] = digest_file

                compiled_file = FS.join(compiled_path, digest_file)
                FS.makeTree(FS.directory compiled_file).then( =>
                  FS.copyTree(pointer['realpath'], compiled_file)
                ).then =>
                  friend.say -> @green "  > #{pointer['id']}"
        ).then =>
          # Update the paths to the digest format:
          collection_view = @ruhoh.resources.load_collection_view(collection.namespace())
          _.extend collection_view._cache, manifest

module.exports = Compiler
