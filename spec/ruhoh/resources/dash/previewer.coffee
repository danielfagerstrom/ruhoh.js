should = require('chai').use(require 'chai-as-promised').should()

Ruhoh = require '../../../../lib/ruhoh'
Previewer = require '../../../../lib/ruhoh/resources/dash/previewer'

describe 'dash previewer', ->
  ruhoh = null
  previewer = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    previewer = new Previewer ruhoh
    ruhoh.setup_all().done ->
      done()

  it 'should respond with a dash page', (done) ->
    previewer.call().done (response) ->
      response.should.include.keys 'status', 'headers', 'body'
      response.status.should.eql 200
      response.headers.should.eql { 'Content-Type': 'text/html' }
      response.body[0].done (body) ->
        body.should.include "pages"
        done()
