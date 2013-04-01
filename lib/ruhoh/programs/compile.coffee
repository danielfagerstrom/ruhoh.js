Q = require 'q'
FS = require 'q-io/fs'
Ruhoh = require '../../ruhoh'

# Public: A program for compiling to a static website.
# The compile environment should always be 'production' in order
# to properly omit drafts and other development-only settings.
exports.compile = (target) ->
  ruhoh = new Ruhoh()
  ruhoh.env = 'production'
  ruhoh.setup_all().then ->

    target = if target
      FS.canonical(target)
    else if ruhoh.config()["compiled"]
      ruhoh.config()["compiled"]
    
    Q.when target, (target) ->
      ruhoh.paths.compiled = target
      ruhoh.compile()
