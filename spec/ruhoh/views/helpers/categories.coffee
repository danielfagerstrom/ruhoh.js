should = require('chai').should()
_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
categories = require '../../../../lib/ruhoh/views/helpers/categories'

CATS = 
  bar: 
    count: 1
    name: 'bar'
    url: '/categories.html#bar-ref'
    pages: [ 'bar.md' ]
  test:
    count: 2
    name: 'test'
    url: '/categories.html#test-ref'
    pages: [ 'bar.md', 'foo.md' ]
CATS.all = [CATS.bar, CATS.test]

describe 'categories helper', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  pages = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    pages = {ruhoh, resource_name: -> 'pages'}
    _.extend pages, categories # mixin
    ruhoh.setup_all(source: path).done ->
      done()

  it 'should return a catgory dict', (done) ->
    pages.categories().done (pagesCategories) ->
      pagesCategories.should.deep.equal CATS
      done()

  it 'should convert category ids to category dicts', (done) ->
    pages.to_categories(['bar', 'test']).done (cats) ->
      cats.should.deep.equal [CATS.bar, CATS.test]
      done()
      