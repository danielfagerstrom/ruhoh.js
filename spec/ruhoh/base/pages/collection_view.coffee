should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
PagesCollection = require '../../../../lib/ruhoh/base/pages/collection'
PagesCollectionView = require '../../../../lib/ruhoh/base/pages/collection_view'

# TODO: no tests for paginator, paginator_navigation

describe 'pages collection view', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  collection_view = null
  model = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new PagesCollection ruhoh
    pointer =
      id: id = 'foo-bar/index.md'
      resource: resource = 'pages'
      realpath: FS.join path, resource, id
    ruhoh.setup_all(source: path).then( ->
      collection_view = new PagesCollectionView collection
      ruhoh.db.get pointer
    ).done (page_data) ->
      model = page_data
      done()

  it 'should be setup', ->
    collection_view.should.include.keys 'collection'

  it 'should create a new mode_view', ->
    cv = collection_view.new_model_view(model)
    cv.should.have.property('title', 'Home')
    cv.should.include.keys 'collection'

  it 'should have a resource name', ->
    collection_view.resource_name().should.equal 'pages'

  it 'should list all pages', (done) ->
    collection_view.all().done (all) ->
      _.pluck(all, 'title').should.eql ['Foo', 'Home']
      done()

  it 'should list all (no) draft pages', (done) ->
    collection_view.drafts().done (drafts) ->
      _.pluck(drafts, 'title').should.eql []
      done()

  it 'should list the latest pages', (done) ->
    collection_view.latest().done (latest) ->
      _.pluck(latest, 'title').should.eql ['Foo', 'Home']
      done()

  it 'should create a collated pages structure', (done) ->
    collection_view.collated().done (collated) ->
      collated[0].year.should.equal "2013"
      collated[0].months.should.have.length 2
      collated[0].months[0].pages.should.have.length 1
      done()

  it 'should list the categories in the collection', (done) ->
    collection_view.categories().should.eventually.include.keys(['all', 'bar']).and.notify(done)

  it 'should list the tags in the collection', (done) ->
    collection_view.tags().should.eventually.include.keys('all', 'foo').and.notify(done)
