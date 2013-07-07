Marbles.Views.MainNavigation = class MainNavigationView extends Marbles.View
  class NavigationItem
    constructor: (@el, @selected_class) ->
      @fragment = Marbles.DOM.attr(@el, 'data-fragment')

      Marbles.DOM.on(@el, 'click', @navigate)

    select: =>
      Marbles.DOM.addClass(@el, @selected_class)

    deselect: =>
      Marbles.DOM.removeClass(@el, @selected_class)

    navigate: (e) =>
      e?.preventDefault()
      Marbles.history.navigate(@fragment, trigger: true)

  constructor: ->
    super

    nav_selected_class = Marbles.DOM.attr(@el, 'data-nav_selected_class')
    @items = for el in Marbles.DOM.querySelectorAll('a', @el)
      new NavigationItem(el, nav_selected_class)

    Marbles.history.on('route', => @highlightActiveItem())
    @highlightActiveItem()

  highlightActiveItem: =>
    for item in @items
      if item.fragment == Marbles.history.fragment
        item.select()
      else
        item.deselect()

