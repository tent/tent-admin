#= require ./posts_common
Marbles.Views.PostsRaw = class PostsRawView extends Marbles.Views.PostsCommon
  @template_name: 'posts_raw'
  @partial_names: ['filter_posts']
  @view_name: 'posts_raw'

  pagination_frozen: true
  pagination: {}
  current_response: {}

  detach: =>
    @detachChildViews()
    super

  initialize: =>
    Marbles.Views.FilterPosts.initTemplates()

    @render()

    @on 'fetch:complete', (res, xhr) =>
      @current_response = res
      @render()
      window.scrollTo(0, 0)

    _params = TentAdmin.queryParams()
    params = {}
    _param_names = Marbles.Views.FilterPosts.feed_param_names
    for k,v of _params
      continue if _param_names.indexOf(k) == -1
      params[k] = v

    @fetch(params, complete: (=> @pagination_frozen = false ))

  fetch: (params, options) =>
    complete = (res, xhr) =>
      if xhr.status in [200...300]
        @pagination = _.extend({
          first: @pagination.first
          last: @pagination.last
        }, res.pages)

        options.success?(res, xhr)
        @trigger('fetch:success', res, xhr)
      else
        options.failure?(res, xhr)
        @trigger('fetch:failure', res, xhr)
      options.complete?(res, xhr)
      @trigger('fetch:complete', res, xhr)

    @constructor.withTentClient (tent_client) =>
      tent_client.post.list(params: params, callback: complete)

  fetchPrev: (options = {}) =>
    return false unless @pagination.prev
    prev_params = Marbles.History::parseQueryParams(@pagination.prev)
    @fetch(prev_params, options)

  fetchNext: (options = {}) =>
    return false unless @pagination.next
    next_params = Marbles.History::parseQueryParams(@pagination.next)
    @fetch(next_params, options)

  context: =>
    _.extend super, {
      response: @current_response
      response_string: JSON.stringify(@current_response, undefined, 2)
    }

  prevPage: =>
    return if @pagination_frozen
    @pagination_frozen = true
    if @fetchPrev(
      complete: => @pagination_frozen = false
    ) is false
      @pagination_frozen = false

  nextPage: =>
    return if @pagination_frozen
    @pagination_frozen = true
    if @fetchNext(
      complete: => @pagination_frozen = false
    ) is false
      @pagination_frozen = false

