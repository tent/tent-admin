#= require lowdash
#= require marbles
#= require_self

window.TentAdmin ?= {}

_.extend window.TentAdmin, Marbles.Events, {
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  config: {}

  run: ->
    return if !Marbles.history || Marbles.history.started

    @showLoadingIndicator()
    @once 'ready', @hideLoadingIndicator

    @on 'loading:start', @showLoadingIndicator
    @on 'loading:stop',  @hideLoadingIndicator

    Marbles.history.start(@config.history_options)

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
