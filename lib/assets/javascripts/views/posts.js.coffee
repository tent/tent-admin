Marbles.Views.Posts = class AppsView extends Marbles.View
  @template_name: 'posts'
  @partial_names: ['_post', '_post_inner']
  @view_name: 'posts'

  @ul_selector: 'ul.posts'
  @last_post_selector: 'li.post:last-of-type'

  pagination_frozen: true

  initialize: =>
    @on 'ready', @initAutoPaginate

    @collection = TentAdmin.Collections.PostsCollection.find(entity: TentAdmin.config.meta.content.entity) || new TentAdmin.Collections.PostsCollection

    @render()

    @collection.on 'reset', (models) =>
      @render(@context(models))

    @collection.on 'append', (models) =>
      @appendRender(models)

    @collection.fetch({}, complete: (=> @pagination_frozen = false ))

  context: (models = @collection.models()) =>
    contextFn = Marbles.Views.Post::context

    posts: _.map models, (model) -> contextFn(model)

  appendRender: (models) =>
    ul = Marbles.DOM.querySelector(@constructor.ul_selector, @el)
    fragment = document.createDocumentFragment()
    template = Marbles.Views.Post.template
    partials = Marbles.Views.Post.partials
    contextFn = Marbles.Views.Post::context

    for model in models
      Marbles.DOM.appendHTML(fragment, template.render(contextFn(model), partials))

    @bindViews(fragment)
    ul.appendChild(fragment)

  nextPage: =>
    @pagination_frozen = true
    if @collection.fetchNext(
      complete: => @pagination_frozen = false
    ) is false
      @last_page = true

  initAutoPaginate: =>
    TentAdmin.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_post = Marbles.DOM.querySelector(@constructor.last_post_selector, @el)
    return unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + Marbles.DOM.windowHeight()

    if last_post_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page
