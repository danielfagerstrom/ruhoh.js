should = require('chai').use(require 'chai-as-promised').should()
{expect} = require('chai')
Q = require 'q'

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
PagesModel = require '../../../../lib/ruhoh/base/pages/model'
PagesModelView = require '../../../../lib/ruhoh/base/pages/model_view'
PagesCollection = require '../../../../lib/ruhoh/base/pages/collection'
PagesCollectionView = require '../../../../lib/ruhoh/base/pages/collection_view'

describe 'page model view', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  collection_view = null
  model_view = null
  model_view_2 = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new PagesCollection ruhoh
    collection_view = null
    pointer =
      id: id = 'foo-bar/index.md'
      resource: resource = 'pages'
      realpath: FS.join path, resource, id
    ruhoh.setup_all(source: path).then( ->
      collection_view = new PagesCollectionView collection
      ruhoh.db.get pointer
    ).done (page_data) ->
      model_view = collection_view.new_model_view page_data
      done()

  # TODO: test content, is_active_page, summary

  describe 'compare', ->

    beforeEach (done) ->
      pointer =
        id: id = 'foo.md'
        resource: resource = 'pages'
        realpath: FS.join __dirname, 'fixtures', resource, id
      ruhoh.db.get(pointer).done (page_data) ->
        model_view_2 = collection_view.new_model_view page_data
        done()

    it 'should order by descending date', ->
      model_view.compare(model_view_2).should.equal 1

  it 'should be initialized', ->
    model_view.should.include.keys ['id', 'url', 'title', 'date', 'layout']

  it 'should have categories', (done) ->
    model_view.categories().done (cats) ->
      cats.should.have.length 1
      cats[0].should.include.keys(['count', 'name', 'url', 'pages'])
      cats[0].name.should.equal 'bar'
      done()

  it 'should have tags', (done) ->
    model_view.tags().done (tags) ->
      tags.should.have.length 1
      tags[0].should.include.keys(['count', 'name', 'url', 'pages'])
      tags[0].name.should.equal 'foo'
      done()

  it 'should have page content', (done) ->
    model_view.get_page_content().should.become(['Home\n', 'foo-bar/index.md']).and.notify(done)

  it 'should have a next sibling', (done) ->
    Q.when(model_view.next(), (next) ->
      next.should.have.property 'title', 'Foo'
    ).done(done())

  it 'should (not) have a previous sibling', (done) ->
    Q.when(model_view.previous(), (previous) ->
      expect(previous).to.be.undefined
    ).done(done())
