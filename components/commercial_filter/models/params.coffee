_ = require 'underscore'
Backbone = require 'backbone'

module.exports = class Params extends Backbone.Model
  urlWhitelist:[
    'page'
    'medium'
    'color',
    'price_range',
    'width',
    'height',
    'gene_id',
    'sort',
    'major_periods',
    'partner_cities'
  ]
  defaults:
    size: 50
    page: 1
    for_sale: true
    color: null
    medium: null
    major_periods: []
    partner_cities: []
    aggregations: ['TOTAL', 'COLOR', 'MEDIUM', 'MAJOR_PERIOD', 'PARTNER_CITY']
    ranges:
      price_range:
        min: 50.00
        max: 50000.00
      width:
        min: 1
        max: 120
      height:
        min: 1
        max: 120

  initialize: (attributes, { @categoryMap, @fullyQualifiedLocations }) ->

  current: ->
    categories = @categoryMap[@get('medium') || 'global']
    extra_aggregation_gene_ids = _.pluck categories, 'id'
    _.extend @attributes, extra_aggregation_gene_ids: extra_aggregation_gene_ids, aggregation_partner_cities: @fullyQualifiedLocations

  whitelisted: ->
    whitelisted = _.pick @current(), @urlWhitelist
    omitted = _.omit whitelisted, (val, key) ->
      (key is 'page' and val is 1) or
      not val?
