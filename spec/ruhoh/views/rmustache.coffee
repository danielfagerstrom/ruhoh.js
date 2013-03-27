should = require('chai').use(require 'chai-as-promised').should()
Q = require 'q'

Mustache = require '../../../lib/ruhoh/views/rmustache'

describe 'rmustache', ->
  view = null

  beforeEach ->
    view =
      foo: 'bar'
      baz: Q.resolve 'quux'
      foo_val: -> (ctx) -> ctx.foo
      length: -> (ctx) -> ctx.length
      dlength: -> (ctx) -> Q.resolve ctx.length
      ddlength: -> Q.resolve((ctx) -> ctx.length)
      to_json: -> (ctx) -> JSON.stringify ctx

  it 'should render a ordinary name', ->
    Mustache.render("{{foo}}", foo: 'bar').should.eql 'bar'

  it 'should render a helper on the view', ->
    Mustache.render("{{?foo_val}}", view).should.eql 'bar'

  it 'should render a helper on a context', ->
    Mustache.render("{{foo?length}}", view).should.eql '3'

  it 'should render a sequence of helpers', ->
    Mustache.render("{{foo?to_json?length}}", view).should.eql '5'

  it 'should render a helper on a deferred context', (done) ->
    Mustache.render("{{baz?length}}", view).should.become('4').and.notify(done)

  it 'should render a helper with a deferred return value on a deferred context', (done) ->
    Mustache.render("{{baz?dlength}}", view).should.become('4').and.notify(done)

  it 'should render a deferred helper on a deferred context', (done) ->
    Mustache.render("{{baz?ddlength}}", view).should.become('4').and.notify(done)
