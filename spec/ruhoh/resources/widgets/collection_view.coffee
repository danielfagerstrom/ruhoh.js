should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
Collection = require '../../../../lib/ruhoh/resources/widgets/collection'
CollectionView = require '../../../../lib/ruhoh/resources/widgets/collection_view'

describe 'widgets collection view', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  collection_view = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    pointer =
      id: id = 'foo.html'
      resource: resource = 'pages'
      realpath: FS.join path, resource, id
    ruhoh.setup_all(source: path).then( ->
      collection = new Collection ruhoh
      collection_view = new CollectionView collection
      collection_view.master = ruhoh.master_view pointer
      collection_view.setup_promise
    ).done ->
      done()

  it 'should setup widget members', ->
    collection_view.should.include.keys "analytics", "comments", "google_prettify"

  it 'should know how to render a widget', (done) ->
    collection_view.widget('google_prettify')
    .should.eventually.include('prettyprint linenums').and.notify(done)
