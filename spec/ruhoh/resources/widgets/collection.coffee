should = require('chai').use(require 'chai-as-promised').should()
FS = require 'q-io/fs'

Ruhoh = require '../../../../lib/ruhoh'
Collection = require '../../../../lib/ruhoh/resources/widgets/collection'

describe 'widgets collection', ->
  path = FS.join __dirname, 'fixtures'
  collection = null

  beforeEach (done) ->
    ruhoh = new Ruhoh()
    ruhoh.setup_all(source: path).done ->
      collection = new Collection ruhoh
      done()

  it 'should initialize path', ->
    collection.path.should.contain 'fixtures/widgets'

  it 'should initialize system path', ->
    collection.system_path.should.contain 'system/widgets'

  it 'should have a list of widget names', (done) ->
    collection.widgets().done (widgets) ->
      widgets.should.include "analytics", "comments", "google_prettify"
      done()
      