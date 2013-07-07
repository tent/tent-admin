Marbles.Views.AppNavigationItem = class AppNavigationItemView extends Marbles.View
  @view_name: 'app_navigation_item'

  initialize: =>
    @fragment = Marbles.DOM.attr(@el, 'data-fragment')
    Marbles.DOM.on(@el, 'click', @navigate)

  navigate: (e) =>
    e?.preventDefault()
    Marbles.history.navigate(@fragment, trigger: true)

