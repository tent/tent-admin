Marbles.Views.AppNavigationItem = class AppNavigationItemView extends Marbles.View
  @view_name: 'app_navigation_item'

  @disableAll: ->
    for cid in Marbles.View.instances.app_navigation_item
      Marbles.View.instances.all[cid]?.disable()

  @enableAll: ->
    for cid in Marbles.View.instances.app_navigation_item
      Marbles.View.instances.all[cid]?.enable()

  initialize: =>
    @fragment = Marbles.DOM.attr(@el, 'data-fragment')
    Marbles.DOM.on(@el, 'click', @navigate)

  navigate: (e) =>
    e?.preventDefault()
    return if @disabled
    Marbles.history.navigate(@fragment, trigger: true)

  disable: =>
    @disabled = true
    Marbles.DOM.addClass(@el, 'disabled')

  enable: =>
    @disabled = false
    Marbles.DOM.removeClass(@el, 'disabled')

