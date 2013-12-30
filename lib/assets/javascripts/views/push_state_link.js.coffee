Marbles.Views.PushStateLink = class PushStateLinkView extends Marbles.View
  @view_name: 'push_state_link'

  initialize: =>
    @href = Marbles.DOM.attr(@el, 'href')
    Marbles.DOM.on @el, 'click', @handleClick

  handleClick: (e) =>
    e?.preventDefault()
    Marbles.history.navigate(@href, trigger: true)
