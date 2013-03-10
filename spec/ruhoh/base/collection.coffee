should = require('chai').use(require 'chai-as-promised').should()

_ = require 'underscore'
FS = require 'q-io/fs'
Ruhoh = require '../../../lib/ruhoh'
BaseCollection = require '../../../lib/ruhoh/base/collection'

describe 'base collection', ->
  path = FS.join __dirname, 'pages/fixtures'
  ruhoh = null
  collection = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    collection = new BaseCollection ruhoh
    collection.resource_name = 'pages'
    ruhoh.setup_all(source: path).done ->
      done()

  it 'should have a namespace', ->
    collection.namespace().should.equal 'pages'

  it 'should have a default glob', ->
    collection.glob().should.equal '**/*'

  it 'should have default paths', ->
    collection.paths().should.eql [
      {name: 'system', path: FS.join(__dirname, '../../..', 'system')}
      {name: 'base', path: FS.join(__dirname, 'pages/fixtures')}
    ]

  it 'should list valid paths', (done) ->
    collection.hasPaths().should.become(true).and.notify(done)

  it 'should have a resource specific config', ->
    collection.config().should.eql(layout: 'docs-2')

  it 'should generate all data resources for this resource type', (done) ->
    collection.generate().done (collection) ->
      collection.should.include.keys('foo-bar/index.md', 'foo.md')
      done()

  it 'should generate a data resource for a specific end point', (done) ->
    collection.generate('foo.md').done (collection) ->
      collection.should.have.property('foo.md')
      collection.should.not.have.property('foo-bar/index.md')
      collection['foo.md'].should.have.deep.property('pointer.resource', 'pages')
      done()

  it 'should generate a filtered list of resources', (done) ->
    collection.generate(null, (f) -> f.match /-.*[^\/]$/).done (collection) ->
      collection.should.not.have.property('foo.md')
      collection.should.have.property('foo-bar/index.md')
      done()

  it 'should collect all files', (done) ->
    collection.files().done (files) ->
      files.should.have.length 2
      done()
      