Marbles.Views.PrevPageLink = class PrevPageLinkView extends Marbles.View
  @view_name: 'prev_page_link'

  initialize: =>
    Marbles.DOM.on @el, 'click', @handleClick

  handleClick: (e) =>
    e?.preventDefault()
    @parentView()?.prevPage()
