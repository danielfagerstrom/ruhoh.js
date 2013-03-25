should = require('chai').use(require 'chai-as-promised').should()
FS = require 'q-io/fs'

Ruhoh = require '../../../../lib/ruhoh'
PagesPreviewer = require '../../../../lib/ruhoh/base/pages/previewer'

describe 'page previewer', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  previewer = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    previewer = new PagesPreviewer ruhoh
    ruhoh.setup_all(source: path).then( ->
      ruhoh.db.routes_initialize()
    ).done ->
      done()

  it 'should respond on /favicon.ico with a favicon', ->
    previewer.call(pathInfo: '/favicon.ico')
    .should.eql status: 200, headers: { 'Content-Type': 'image/x-icon' },  body: [ '' ]

  it 'should respond on /pages/foo', (done) ->
    response = previewer.call(pathInfo: '/pages/foo')
    response.should.include.keys 'status', 'headers', 'body'
    response.status.should.eql 200
    response.headers.should.eql { 'Content-Type': 'text/html' }
    response.body[0].done (body) ->
      body.should.eql "<div>\n<p>Foo Page</p>\n\n</div>\n"
      done()
      
  it 'should respond on /pages/1', (done) ->
    response = previewer.call(pathInfo: '/pages/1')
    response.should.include.keys 'status', 'headers', 'body'
    response.status.should.eql 200
    response.headers.should.eql { 'Content-Type': 'text/html' }
    response.body[0].done (body) ->
      body.should.eql """
        <dl>
          <dt>Foo</dt><dd><p>Foo Page</p>
        </dd>
          <dt>Home</dt><dd><p>Home</p>
        </dd>
        </dl>

      """
      done()
      
