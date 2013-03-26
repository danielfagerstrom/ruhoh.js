should = require('chai').use(require 'chai-as-promised').should()

Ruhoh = require '../../../../lib/ruhoh'
Collection = require '../../../../lib/ruhoh/resources/stylesheets/collection'
CollectionView = require '../../../../lib/ruhoh/resources/stylesheets/collection_view'

describe 'stylesheets collection view', ->
  ruhoh = null
  collection_view = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new Collection ruhoh
    ruhoh.setup_all().done ->
      collection_view = new CollectionView collection
      done()

  it 'should create stylesheet includes', ->
    includes = collection_view.load()("""
      global.css
      custom.css
    """)
    includes.should.include "/assets/stylesheets/global.css?"
    includes.should.include "/assets/stylesheets/custom.css?"
