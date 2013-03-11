should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
PagesModel = require '../../../../lib/ruhoh/base/pages/model'
PagesModelView = require '../../../../lib/ruhoh/base/pages/model_view'

describe 'page model', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  model_view = null
  model_view_2 = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    pointer =
      id: id = 'foo-bar/index.md'
      resource: resource = 'pages'
      realpath: FS.join __dirname, 'fixtures', resource, id
    ruhoh.setup_all(source: path).then( ->
      ruhoh.db.get pointer
    ).done (page_data) ->
      model_view = new PagesModelView ruhoh, page_data
      done()

  # TODO: test categories, tags, content, is_active_page, summary, next, previous

  describe 'compare', ->

    beforeEach (done) ->
      pointer =
        id: id = 'foo.md'
        resource: resource = 'pages'
        realpath: FS.join __dirname, 'fixtures', resource, id
      ruhoh.db.get(pointer).done (page_data) ->
        model_view_2 = new PagesModelView ruhoh, page_data
        done()

    it 'should order by descending date', ->
      # FIXME: setup with real collection views
      model_view.collection = resource_name: 'pages'
      model_view_2.collection = resource_name: 'pages'
      model_view.compare(model_view_2).should.equal 1

  it 'should be initialized', ->
    model_view.should.include.keys ['id', 'url', 'title', 'date', 'layout']

  it 'should have page content', (done) ->
    model_view.get_page_content().should.become(['Home\n', 'foo-bar/index.md']).and.notify(done)

