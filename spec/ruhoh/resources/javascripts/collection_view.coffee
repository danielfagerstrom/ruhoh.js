should = require('chai').use(require 'chai-as-promised').should()

Ruhoh = require '../../../../lib/ruhoh'
Collection = require '../../../../lib/ruhoh/resources/javascripts/collection'
CollectionView = require '../../../../lib/ruhoh/resources/javascripts/collection_view'

describe 'javascripts collection view', ->
  ruhoh = null
  collection_view = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new Collection ruhoh
    ruhoh.setup_all().done ->
      collection_view = new CollectionView collection
      done()

  it 'should create javascript includes', ->
    includes = collection_view.load()("""
      app.js
      scroll.js
    """)
    includes.should.include "/assets/javascripts/app.js?"
    includes.should.include "/assets/javascripts/scroll.js?"
