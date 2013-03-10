should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
PagesCollection = require '../../../../lib/ruhoh/base/pages/collection'

describe 'pages collection', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  collection = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new PagesCollection ruhoh
    ruhoh.setup_all(source: path).done ->
      done()

  it 'should have a namespace', ->
    collection.namespace().should.equal 'pages'

  it 'should have a resource specific config', ->
    collection.config().should.eql(
      layout: 'docs-2'
      permalink: '/:path/:filename'
      summary_lines: 20
      latest: 2
      rss_limit: 20
      ext: '.md'
      paginator:
        namespace: '/index'
        per_page: 5
        layout: 'paginator'
    )
