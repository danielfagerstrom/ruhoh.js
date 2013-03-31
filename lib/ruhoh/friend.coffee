{puts} = require 'util'

codes =
  bold: 1
  red: 31
  green: 32
  yellow: 33
  blue: 34
  magenta: 35
  cyan: 36
  white: 37

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
  
for name, code of codes
  do (code) ->
    friend[name] = (text) ->
      @color(text, "\x1B[#{code}m")


module.exports = friend