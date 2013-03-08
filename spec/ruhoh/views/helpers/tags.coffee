should = require('chai').should()
_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
tags = require '../../../../lib/ruhoh/views/helpers/tags'

TAGS =
  a: 
     count: 2
     name: 'a'
     url: '/tags.html#a-ref'
     pages: [ 'bar.md', 'foo.md' ]
  b: 
     count: 1
     name: 'b'
     url: '/tags.html#b-ref'
     pages: [ 'foo.md' ]
TAGS.all = [TAGS.a, TAGS.b]

describe 'tags helper', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  pages = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    pages = {ruhoh, resource_name: 'pages'}
    _.extend pages, tags # mixin
    ruhoh.setup_all(source: path).done ->
      done()

  it 'should return a tags dict', (done) ->
    pages.tags().done (tags) ->
      tags.should.deep.equal TAGS
      done()

  it 'should convert tag ids to tag dicts', (done) ->
    pages.to_tags(['a', 'b']).done (tags) ->
      tags.should.deep.equal [TAGS.a, TAGS.b]
      done()
