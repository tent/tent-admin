Marbles.Views.PostJSONToggle = class PostJSONToggleView extends Marbles.View
  @view_name: 'post_json_toggle'

  detach: =>
    Marbles.DOM.off(@el, 'click', @handleClick)
    super

  initialize: =>
    @target = Marbles.DOM.attr(@el, 'data-target')
    Marbles.DOM.on @el, 'click', @handleClick

  handleClick: (e) =>
    e?.preventDefault()
    if @target == 'json'
      @parentView().renderJSON()
    else
      @parentView().render()

