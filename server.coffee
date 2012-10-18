#!/usr/bin/env coffee
express = require 'express'
program = require 'commander'
glob = require 'glob'

program
  .option('-p --port <port>', 'Server port <9292>', 9292)
  .parse(process.argv)
  
listFiles = (pattern, next) ->
  glob pattern, {cwd: __dirname, root: __dirname, nomount: true}, (err, files) ->
    next err, files
    
app = express()
app.use(express.logger 'dev')
  .use(app.router)
  .use(express.static __dirname)

app.get '/', (req, res, next) ->
  if req.query.pattern?
    pattern = req.query.pattern
    res.send 403 unless pattern.indexOf('..') is -1
    listFiles pattern, (err, files) ->
      return next err if err 
      res.send files
  else
    next()

app.listen program.port
console.log "Listening on port #{program.port}"
