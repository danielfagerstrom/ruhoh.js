require 'colors'
{puts} = require 'util'
module.exports =
  say: (str) ->
    puts str

  list: (caption, listings) ->
    puts " #{caption}".red
    for key, value of listings
      puts "    - #{key}".cyan
      puts "      #{value}".cyan

