Q = require 'bluebird-q'
_ = require 'underscore'
StepView = require './step.coffee'
Form = require '../../form/index.coffee'
defaultMessage = require '../../contact/default_message.coffee'
ArtworkInquiry = require '../../../models/artwork_inquiry.coffee'
alertable = require '../../alertable_input/index.coffee'
template = -> require('../templates/inquiry.jade') arguments...

module.exports = class Inquiry extends StepView
  template: (data) ->
    template _.extend data,
      fair: @artwork.related().fairs.first()
      message: @inquiry.get('message') or @defaultMessage()

  __events__:
    'click button': 'serialize'

  defaultMessage: ->
    defaultMessage @artwork, @artwork.related().partner

  nudged: false

  serialize: (e) ->
    e.preventDefault()

    form = new Form model: @inquiry, $form: @$('form')

    nudge =
      $input: @$('textarea')
      message: 'We recommend personalizing your message to get a faster answer from the gallery.'
      $submit: @$('button')
      label: 'Send Anyway?'

    if not @nudged and alertable(nudge, ((value) => value is @defaultMessage()))
      @nudged = true
      return

    return unless form.isReady()

    form.state 'loading'

    { attending } = data = form.serializer.data()

    if attending
      @user
        .related().collectorProfile
        .related().userFairActions.attendFair @artwork.related().fairs.first()

    @__serialize__ = Q.all [
      @inquiry.save _.extend { contact_gallery: true }, data
      @user.save @inquiry.pick('name', 'email')
    ]
      .then =>
        Q.allSettled(
          @user
            .related().collectorProfile
            .related().userFairActions.invoke 'save'
        )
      .then =>
        @next()
      , (e) ->
        form.error null, e
