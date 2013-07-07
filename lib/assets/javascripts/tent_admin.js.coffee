#= require lodash
#= require marbles
#= require tent-client
#= require ./config
#= require_self
#= require_tree ./routers
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./models
#= require_tree ./collections

window.TentAdmin ?= {}
_.extend window.TentAdmin, Marbles.Events, {
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  run: ->
    Marbles.View.templates ?= window.LoDashTemplates
    return if !Marbles.history || Marbles.history.started

    @showLoadingIndicator()
    @once 'ready', @hideLoadingIndicator

    @on 'loading:start', @showLoadingIndicator
    @on 'loading:stop',  @hideLoadingIndicator

    @config.container ?= { el: document.getElementById('main') }

    # find any view bindings before client-side views are rendered
    main_view = new Marbles.View el: document
    main_view.bindViews()

    Marbles.DOM.on window, 'scroll', (e) => @trigger 'window:scroll', e

    Marbles.history.start(root: (@config.PATH_PREFIX || '') + '/')

    @ready = true
    @trigger 'ready'

  showLoadingIndicator: ->
    @_num_running_requests ?= 0
    @_num_running_requests += 1
    Marbles.Views.loading_indicator?.show() if @_num_running_requests == 1

  hideLoadingIndicator: ->
    @_num_running_requests ?= 1
    @_num_running_requests -= 1
    Marbles.Views.loading_indicator?.hide() if @_num_running_requests == 0
}

TentAdmin.trigger('config:ready') if TentAdmin.config_ready

