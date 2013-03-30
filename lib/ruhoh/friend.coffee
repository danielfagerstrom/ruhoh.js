require 'colors'
{puts} = require 'util'

# The Friend is good for conversation.
# He tells you what's going on.
# Implementation is largely copied from rspec gem: http://rspec.info/
friend =
  say: (block) ->
    if typeof block is 'function'
      block.call this
    else
      puts block

  # TODO: Adds ability to disable if color is not supported?
  is_color_enabled: ->
    true
      
  list: (caption, listings) ->
    @red "  #{caption}"
    for key, value of listings
      @cyan "    - #{key}"
      @cyan "      #{value}"

  color: (text, color_code) ->
    puts if @is_color_enabled() then "#{color_code}#{text}\x1B[0m" else text

  plain: (text) ->
    puts text
  
  bold: (text) ->
    @color(text, "\x1B[1m")

  red: (text) ->
    @color(text, "\x1B[31m")

  green: (text) ->
    @color(text, "\x1B[32m")

  yellow: (text) ->
    @color(text, "\x1B[33m")

  blue: (text) ->
    @color(text, "\x1B[34m")

  magenta: (text) ->
    @color(text, "\x1B[35m")

  cyan: (text) ->
    @color(text, "\x1B[36m")

  white: (text) ->
    @color(text, "\x1B[37m")


module.exports = friend