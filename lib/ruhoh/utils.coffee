YAML = require 'js-yaml'
path = require 'path'
FS = require 'q-io/fs'
_ = require 'underscore'
log = require './logger'
friend = require './friend'

# Simplify getter and setters in coffeescript see http://stackoverflow.com/a/11592890
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

module.exports =
  FMregex: /^(---\s*\n[^]*?\n?)^(---\s*$\n?)/m
  
  parse_yaml_file: (args...) ->
    filepath = path.join args...
    FS.exists(filepath).then( (exists) ->
      return null unless exists

      FS.read(filepath).then (file) ->
        try
          YAML.load(file) || {}
        catch e
          log.error("ERROR in #{filepath}: #{e.message}")
          null
    )

  url_to_path: (url, base=null) ->
    url = url.replace(/^\//, '')
    parts = url.split('/')
    parts.unshift(base) if base
    path.join parts...

  to_url_slug: (title) ->
    encodeURIComponent @to_slug(title)
  
  # My Post Title ===> my-post-title
  to_slug: (title) ->
    title = (title ? '').toLowerCase().trim().replace(/[\W+]/g, '-') # FIXME: /[^\p{Word}+]/u in original
    title.replace(/^\-+/, '').replace(/\-+$/, '').replace(/\-+/, '-')
  
  report: (name, collection, invalid) ->
    count = (dict) -> _.keys(dict).length
    output = "#{count(collection)}/#{count(collection) + count(invalid)} #{name} processed."
    if _.isEmpty(collection) and _.isEmpty(invalid)
      friend.say "0 #{name} to process."
    else if _.isEmpty(invalid)
      friend.say output.green
    else
      friend.say output.yellow
      friend.list "#{name} not processed:", invalid
  
  # Merges hash with another hash, recursively.
  #
  # Adapted from Jekyll which got it from some gem whose link is now broken.
  # Thanks to whoever made it.
  deep_merge: (hash1, hash2) ->
    target = _.clone hash1

    for key of hash2
      if _.isObject(hash2[key]) and _.isObject(hash1)
        target[key] = @deep_merge target[key], hash2[key]
        continue
      target[key] = hash2[key]
    target
  
  # Thanks ActiveSupport: http://stackoverflow.com/a/1509939/101940
  underscore: (string) ->
    (string ? '').
    replace(/::/g, '/').
    replace(/([A-Z]+)([A-Z][a-z])/g,'$1_$2').
    replace(/([a-z\d])([A-Z])/g,'$1_$2').
    replace("-", "_").
    toLowerCase()

  ###
  # Seem to be Ruby namespace specific
  # 
  constantize: (class_name) ->
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
      raise NameError, "#{class_name.inspect} is not a valid constant name!"

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  ###

  # see http://stackoverflow.com/a/3561711
  escapeRegExp: (str) ->
    str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

  chomp: (string, separator=/(\n|\r)+$/) ->
    separator = new RegExp(@escapeRegExp(separator) + "$") unless _.isRegExp separator
    string.replace separator, ''

  compare: (a, b) ->
    if a < b then -1 else if a > b then 1 else 0