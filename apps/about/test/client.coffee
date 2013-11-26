benv            = require 'benv'
rewire          = require 'rewire'
Backbone        = require 'backbone'
sinon           = require 'sinon'
Page            = require '../../../models/page.coffee'
mediator        = require '../../../lib/mediator.coffee'
{ fabricate }   = require 'antigravity'

describe 'AboutRouter', ->
  before (done) ->
    benv.setup =>
      benv.expose { $: require 'components-jquery' }
      Backbone.$ = $
      Backbone.history.start = sinon.stub
      done()

  beforeEach (done) ->
    page = new Page fabricate 'page'
    benv.render '../template.jade', {
      sd: {},
      page: page,
      nav: page
    }, =>
      { @AboutRouter, @init } = require '../client'
      @router = new @AboutRouter
      # The fabricated page doesnt have nav content; insert an example
      $('#about-page-nav').prepend('<a href="/about/jobs"></a>')
      @init() # Attach click handlers
      done()

  describe 'AboutView', ->
    describe '#initialize', ->
      it 'should render a jump navigation and set its right CSS prop to inherit', ->
        @router.$jumpContainer.html().should.include 'jump-to-top'
        @router.$jumpContainer.html().should.include 'right: inherit'

    describe 'events', ->
      beforeEach ->
        sinon.spy @AboutRouter.prototype, 'navigate'

      afterEach ->
        @router.navigate.restore()

      describe '#toTop', ->
        it 'triggers a event for /about', ->
          @router.$jumpContainer.click()
          @router.navigate.args[0][0].should.equal '/about'

      describe '#toSection', ->
        it 'triggers an event for the slug of the link', ->
          $('#about-page-nav a').first().click()
          @router.navigate.args[0][0].should.equal '/about/jobs'

    describe '#positionFromSlug', ->
      it 'should return the distance from the top, minus the header height, of a given section heading'
