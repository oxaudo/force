_ = require 'underscore'
Backbone = require 'backbone'
ContactView = require './view.coffee'
analytics = require '../../lib/analytics.coffee'
CurrentUser = require '../../models/current_user.coffee'
Cookies = require 'cookies-js'
defaultMessage = require './default_message.coffee'
{ SESSION_ID, API_URL } = require('sharify').data
formTemplate = -> require('./templates/inquiry_form.jade') arguments...
headerTemplate = -> require('./templates/inquiry_partner_header.jade') arguments...

module.exports = class ContactPartnerView extends ContactView
  eligibleForAfterInquiryFlow: true

  # Prevents clicks on the backdrop from closing
  # the contact form
  events: -> _.extend super,
    'click.handler .modal-backdrop': undefined

  headerTemplate: (locals) =>
    headerTemplate _.extend locals,
      artwork: @artwork
      partner: @partner
      user: @user

  formTemplate: (locals) =>
    formTemplate _.extend locals,
      artwork: @artwork
      user: @user
      contactGallery: true
      defaultMessage: defaultMessage(@artwork, @partner)

  defaults: -> _.extend super,
    url: "#{API_URL}/api/v1/me/artwork_inquiry_request"
    successMessage: 'Thank you. Your inquiry has been sent.'

  initialize: (options) ->
    { @artwork, @partner } = options

    @partner.locations().fetch complete: =>
      @renderTemplates()
      @renderLocation()
      @updatePosition()
      @isLoaded()

      if @user
        @focusTextareaAfterCopy()
      else
        @$('[name="name"]').focus()

    super

  renderLocation: =>
    return if @partner.locations().length > 1
    return unless city = @partner.displayLocations @user?.get('location')?.city
    @$('.contact-location').html ", " + city

  submit: ->
    analytics.track.funnel 'Sent artwork inquiry',
      label: analytics.modelNameAndIdToLabel('artwork', @artwork.id)

    @model.set
      artwork: @artwork.id
      contact_gallery: true
      session_id: SESSION_ID
      referring_url: Cookies.get('force-referrer')
      landing_url: Cookies.get('force-session-start')
      inquiry_url: window.location.href

    super

    changed = if @model.get('message') is defaultMessage(@artwork, @partner) then 'Did not change' else 'Changed'
    analytics.track.funnel "#{changed} default message"
    analytics.track.funnel "Inquiry: Original Flow", SESSION_ID
    analytics.snowplowStruct 'inquiry_original_flow', 'saw', SESSION_ID, 'user'

  postRender: =>
    @isLoading()
