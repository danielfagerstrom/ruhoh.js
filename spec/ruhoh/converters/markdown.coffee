should = require('chai').should()
markdown = require '../../../lib/ruhoh/converters/markdown'

describe 'markdown', ->
  it 'should handle extensions .md and .markdown', ->
    markdown.extensions.should.include('.md').and.include('.markdown').with.length 2

  it 'should convert markdown to html', ->
    markdown.convert('i am using __markdown__.')
    .should.equal '<p>i am using <strong>markdown</strong>.</p>\n'
    