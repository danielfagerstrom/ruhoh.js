should = require('chai').use(require 'chai-as-promised').should()
URL = require 'url'
FS = require 'q-io/fs'
HTTP = require 'q-io/http'
Q = require 'q'

{preview} = require '../../../lib/ruhoh/programs/preview'



describe 'preview', ->
  path = FS.join __dirname, 'fixtures'
  app = null
  callApp = (request) ->
    request = HTTP.normalizeRequest request
    request.pathInfo ?= URL.parse(request.url).pathname
    Q.when app(request), (resp) ->
      Q.when resp.body, (body) ->
        chunks = []
        Q.when body.forEach((part) -> chunks.push Q.when(part)), ->
          Q.all(chunks).then (body) ->
            status: resp.status
            headers: resp.headers
            body: body.join ''

  beforeEach (done) ->
    preview(source: path).done (app_) ->
      app = app_
      done()

  it 'should preview urls to resources that has a previewer', (done) ->
    callApp('http://localhost/dash').done (response) ->
      response.status.should.equal 200
      response.headers.should.have.property 'Content-Type', 'text/html'
      response.body.should.include 'id="pages"'
      done()

  it 'should preview urls to resources without a previewer', (done) ->
    callApp('http://localhost/assets/stylesheets/foo.css').done (response) ->
      response.status.should.equal 200
      response.headers.should.have.property 'content-type', 'text/css'
      response.body.should.include 'h1 { color: #000000; }'
      done()

  it 'should preview urls to page like resources', (done) ->
    callApp('http://localhost/pages/foo').done (response) ->
      response.status.should.equal 200
      response.headers.should.have.property 'Content-Type', 'text/html'
      response.body.should.include 'bar'
      done()

