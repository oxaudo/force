Backbone = require 'backbone'
Q = require 'bluebird-q'
template = require '../templates/email_to_registration_transition.jade'

module.exports = class EmailToRegistrationTransitionView extends Backbone.View
  deferred = Q.defer()

  events:
    'click .email-to-registration-transition-register': 'register'
    'click .email-to-registration-transition-skip': 'skip'

  initialize: ->
    @result = deferred.promise

  render: ->
    @$el.html template()
    this

  register: ->
    @trigger('done')
    deferred.resolve(true)

  skip: ->
    @trigger('done')
    deferred.resolve(false)

  remove: ->
    deferred.reject()
    super
