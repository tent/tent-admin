Marbles.Views.NextPageLink = class NextPageLinkView extends Marbles.View
  @view_name: 'next_page_link'

  initialize: =>
    Marbles.DOM.on @el, 'click', @handleClick

  handleClick: (e) =>
    e?.preventDefault()
    @parentView()?.nextPage()
