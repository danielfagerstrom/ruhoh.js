should = require('chai').should()
converter = require '../../lib/ruhoh/converter'

describe 'converter', ->
  it 'should apply the converter for a specific extension', ->
    converter.convert('I am using __markdown__.', 'foo.md').should
    .eql '<p>I am using <strong>markdown</strong>.</p>\n'

  it 'should contein all extensions', ->
    converter.extensions().should.eql ['.md', '.markdown']
    