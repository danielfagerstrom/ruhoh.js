should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../../lib/ruhoh'
PagesModel = require '../../../../lib/ruhoh/base/pages/model'

describe 'page model', ->
  path = FS.join __dirname, 'fixtures'
  ruhoh = null
  model = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    model = new PagesModel(
      ruhoh
    ,
      id: id = 'foo-bar/index.md'
      resource: resource = 'pages'
      realpath: FS.join __dirname, 'fixtures', resource, id
    )
    ruhoh.setup_all(source: path).done ->
      done()

  it 'should generate page data to be registred in the db', (done) ->
    model.generate().done (result) ->
      result.should.eql(
        'foo-bar/index.md':
          title: 'Home'
          date: new Date("2013-03-08")
          layout: 'page'
          pointer: 
            id: 'foo-bar/index.md'
            resource: 'pages'
            realpath: '/home/daniel/dev/ruhoh.js/spec/ruhoh/base/pages/fixtures/pages/foo-bar/index.md'
          id: 'foo-bar/index.md'
          url: '/pages/foo-bar/index.md'
      )
      done()

  it 'should return page content', (done) ->
    model.content().should.become('Home\n').and.notify(done)

  it 'should parse a page file', (done) ->
    model.parse_page_file()
    .should.become(
      data:
        title: "Home"
        date: new Date("2013-03-08")
        layout: "page"
      content:
        'Home\n'
    ).and.notify(done)

  it 'should parse an empty page filename', ->
    model.parse_page_filename('').should.be.empty

  it 'should parse an ordinary page filename', ->
    model.parse_page_filename('foo/bar/page.md').should.eql(
      path: 'foo/bar/'
      slug: 'page'
      title: 'Page'
      extension: '.md'
    )

  it 'should parse a page filename with a date', ->
    model.parse_page_filename('foo/bar/2013-03-09-my-page.md').should.eql(
      path: 'foo/bar/'
      date: '2013-03-09'
      slug: 'my-page'
      title: 'My Page'
      extension: '.md'
    )

  it 'should convert a slug to a title', ->
    model.to_title('foo-bar').should.equal 'Foo Bar'

  it 'should convert an "index" slug to a title', ->
    model.to_title('index').should.equal 'Foo Bar'

  it 'should create a permalink from page data', ->
    model.permalink(
      permalink: '/:path/:year/:month/:day/:title'
      title: 'My Page'
      id: 'foo/bar.md'
      date: '2013-03-09'
    ).should.equal '/pages/foo/2013/03/09/my-page'

  it 'should create a permalink from page data 2', ->
    model.permalink(
      permalink: '/:relative_path/:categories/:i_month/:i_day/:filename'
      categories: ['a', 'b']
      id: 'foo/bar.md'
      date: '2013-03-09'
    ).should.equal '/foo/a/3/9/bar.md'

  it 'should create a permalink from a literal permalink config', ->
    model.permalink(permalink: '/foo/bar').should.equal '/foo/bar'
    
