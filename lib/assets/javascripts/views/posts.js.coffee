#= require ./posts_common
Marbles.Views.Posts = class PostsView extends Marbles.Views.PostsCommon
  @template_name: 'posts'
  @partial_names: ['_post', '_post_inner', 'filter_posts']
  @view_name: 'posts'

  @ul_selector: 'ul.posts'
  @last_post_selector: 'li.post:last-of-type'

  pagination_frozen: true

  detach: =>
    @detachChildViews()
    if @collection
      for cid in @collection.model_ids
        Marbles.Model.detach(cid)
      @collection.detach()
    super

  initialize: =>
    Marbles.Views.FilterPosts.initTemplates()

    @constructor.withTentClient (tent_client) =>
      @collection = new TentAdmin.Collections.PostsCollection()
      @collection.options.tent_client = tent_client

      @render()

      @collection.on 'reset', (models) =>
        @render(@context(models))

      @collection.on 'append', (models) =>
        @appendRender(models)

      @collection.on 'prepend', (models) =>
        @prependRender(models)

      _params = TentAdmin.queryParams()
      params = {}
      _param_names = Marbles.Views.FilterPosts.feed_param_names
      for k,v of _params
        continue if _param_names.indexOf(k) == -1
        params[k] = v

      @collection.fetch(params, complete: (=> @pagination_frozen = false ))

  context: (models = @collection.models()) =>
    contextFn = Marbles.Views.Post::context

    _.extend super(), {
      posts: _.map(models, (model) -> contextFn(model)),
      lastPage: @last_page
    }

  buildChildren: (models) =>
    fragment = document.createDocumentFragment()
    template = Marbles.Views.Post.template
    partials = Marbles.Views.Post.partials
    contextFn = Marbles.Views.Post::context

    for model in models
      Marbles.DOM.appendHTML(fragment, template.render(contextFn(model), partials))

    fragment

  prependRender: (models) =>
    ul = Marbles.DOM.querySelector(@constructor.ul_selector, @el)

    fragment = @buildChildren(models)

    @bindViews(fragment)
    Marbles.DOM.prependChild(ul, fragment)

  appendRender: (models) =>
    ul = Marbles.DOM.querySelector(@constructor.ul_selector, @el)

    fragment = @buildChildren(models)

    @bindViews(fragment)
    ul.appendChild(fragment)

  prevPage: =>
    return if @pagination_frozen
    @pagination_frozen = true
    if @collection.fetchPrev(
      complete: => @pagination_frozen = false
    ) is false
      @pagination_frozen = false

  nextPage: =>
    @pagination_frozen = true
    if @collection.fetchNext(
      complete: => @pagination_frozen = false
    ) is false
      @last_page = true

