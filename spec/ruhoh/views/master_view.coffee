should = require('chai').use(require 'chai-as-promised').should()
_ = require 'underscore'
Q = require 'q'
FS = require 'q-io/fs'
Ruhoh = require '../../../lib/ruhoh'
MasterView = require '../../../lib/ruhoh/views/master_view'

# TODO: no tests for to_json, to_pretty_json, debug, raw_code, to_slug, compiled_path

describe 'master view', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  master_view = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    pointer =
      id: id = 'foo.md'
      resource: resource = 'pages'
      realpath: FS.join path, resource, id
    ruhoh.setup_all(source: path).done ->
      master_view = new MasterView ruhoh, pointer
      done()

  it 'should be initialized from a pointer', (done) ->
    master_view.page_data.should.eventually.have.property('url', '/pages/foo.md').and.notify(done)

  it 'should render a full page', (done) ->
    master_view.render_full().done (result) ->
      result.should.eql("<body>\n<div>\ntitle: Foo\n\n</div>\n\n</body>\n")
      done()

  it 'should render the page content', (done) ->
    # master_view.render_content().should.become('title: Foo\n').and.notify(done)
    master_view.render_content().done (result) ->
      result.should.eql('title: Foo\n')
      done()

  it 'should render a template', (done) ->
    master_view.render('-- {{page.title}} --').should.become('-- Foo --').and.notify(done)

  it 'should create a page view', (done) ->
    Q.when(master_view.page(), (page) ->
      page.should.have.property('title', 'Foo')
    ).done -> done()

  it 'should return the collection for the current pointer', ->
    master_view.collection().resource_name().should.equal 'pages'

  it 'should return a list of url base paths', ->
    master_view.urls().should.have.property('dash', '/dash')

  it 'should render its content', (done) ->
    master_view.content().should.become('title: Foo\n').and.notify(done)

  it 'should return a named partial', (done) ->
    master_view.partial('posts_list')
    .should.become('<li><a href=\"{{url}}\">{{title}}</a></li>\n').and.notify(done)
      
