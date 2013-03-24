Q = require 'q'
_ = require 'underscore'
FS = require 'q-io/fs'
moment = require 'moment'

BaseCollectionView = require '../collection_view'
categories = require '../../views/helpers/categories'
tags = require '../../views/helpers/tags'

class CollectionView extends BaseCollectionView
  _.extend @prototype, categories # mixin
  _.extend @prototype, tags # mixin

  all: ->
    @ruhoh.db[@resource_name()]().then (items) =>
      _.compact(for key, data of items when FS.base(FS.directory(data['id'])) isnt "drafts"
        @new_model_view(data)
      ).sort((a, b) -> a.compare(b))

  drafts: ->
    @ruhoh.db[@resource_name()]().then (items) =>
      _.compact(for key, data of items when FS.base(FS.directory(data['id'])) is "drafts"
        @new_model_view(data)
      ).sort((a, b) -> a.compare(b))

  latest: ->
    latest = @ruhoh.db.config(@resource_name())['latest']
    latest ||= 10
    @all().then (all) ->
      if (latest > 0) then all[0...latest] else all

  # current_page is set via a compiler or previewer
  # in which it can discern what current_page to serve
  paginator: ->
    Q.when(@master.page_data).then (page_data) =>
      per_page = @ruhoh.db.config(@resource_name())["paginator"]?["per_page"] ? 5
      current_page = page_data['current_page'] ? 0
      current_page = if current_page is 0 then 1 else current_page
      offset = (current_page-1)*per_page

      @all().then (all) ->
        page_batch = all[offset...per_page]
        throw new Error "Page does not exist" unless page_batch
        page_batch

  paginator_navigation: ->
    Q.when(@master.page_data).then (page_data) =>
      config = @ruhoh.db.config(@resource_name())["paginator"] || {}
      @all().then (all) =>
        page_count = all.length
        total_pages = Math.ceil(page_count/config["per_page"])
        current_page = page_data['current_page'] ? 0
        current_page = if current_page is 0 then 1 else current_page

        pages = for i in [0...total_pages]
          url = if i is 0 && config["root_page"]
            config["root_page"]
          else
            "#{config['namespace']}/#{i+1}"
          
          {
            "url": @ruhoh.to_url(url),
            "name": "#{i+1}",
            "is_active_page": (i+1 == current_page)
          }
        pages 

  # Internal: Create a collated pages data structure.
  #
  # pages - Required [Array] 
  #  Must be sorted chronologically beforehand.
  #
  # @returns[Array] collated pages:
  # [{ 'year': year, 
  #   'months' : [{ 'month' : month, 
  #     'pages': [{}, {}, ..] }, ..] }, ..]
  collated: ->
    collated = []
    @all().then (pages) =>
      for {id, date} in pages
        thisYear = moment(date).format('YYYY')
        thisMonth = moment(date).format('MMMM')

        if thisYear isnt prevYear # create new year
          collated.push year: thisYear, months: months = []
          prevYear = thisYear

        if thisMonth isnt prevMonth # create new month
          month = month: thisMonth
          month[@resource_name()] = (resources = [])
          months.push month
          prevMonth = thisMonth

        resources.push id

      collated

module.exports = CollectionView