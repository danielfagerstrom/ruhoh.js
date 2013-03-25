should = require('chai').use(require 'chai-as-promised').should()
FS = require 'q-io/fs'

Ruhoh = require '../../../../lib/ruhoh'
Collection = require '../../../../lib/ruhoh/resources/data/collection'
CollectionView = require '../../../../lib/ruhoh/resources/data/collection_view'

describe 'data collection view', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  collection_view = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new Collection ruhoh
    ruhoh.setup_all(source: path).done ->
      collection_view = new CollectionView collection
      done()

  it 'should contain the data configuration', (done) ->
    collection_view.setup_promise.done (collection_view) ->
      collection_view.should.have.property('title', 'ruhoh')
      collection_view.should.have.property('tagline', 'Site Tagline')
      done()
      