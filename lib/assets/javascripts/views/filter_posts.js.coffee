Marbles.Views.FilterPosts = class FilterPostsView extends Marbles.View
  @feed_param_names: ['limit', 'sort_by', 'since', 'until', 'before', 'entities', 'types', 'mentions', 'max_refs']

  @template_name: 'filter_posts'
  @partial_names: (_.map @feed_param_names, (name) -> "filter_posts/#{name}").concat(['filter_posts/available_params'])
  @view_name: 'filter_posts'

  @feed_params: {}
  @available_feed_param_names: []

  @parseParams: ->
    query_string = window.location.search

    if query_string.substr(0, 1) == '?'
      query = query_string.substr(1, query_string.length).split('&')
    else
      query = query_string.split('&')

    params = {}
    for q in query
      [key,val] = q.split('=')
      continue unless val
      val = decodeURIComponent(val).replace('+', ' ') # + doesn't decode
      val = val.split(',') if val.indexOf(',') != -1
      if !params.hasOwnProperty(key)
        params[key] = []
      params[key].push(val)
    params

  @serializeParams: (params) ->
    query = []
    for key,values of params
      for val in values
        val = val.join(',') if _.isArray(val)
        continue if val?.match?(/^[\s\r\t\n]*$/)
        query.push("#{key}=#{encodeURIComponent(val)}")
    "?" + query.join("&")

  @updateParams: (handler, fragment, params) ->
    params = @parseParams()

    feed_params = {}
    for k in @feed_param_names
      continue unless params.hasOwnProperty(k)
      feed_params[k] = params[k]
    @feed_params = feed_params

    @available_feed_param_names = _.reject @feed_param_names, (name) ->
      name != 'mentions' && feed_params.hasOwnProperty(name)

  @serializeForm: (form) =>
    params = {}

    for el in form.querySelectorAll('[name]')
      name = Marbles.DOM.attr(el, 'name')
      value = null
      if el.nodeName.toLowerCase() == 'select'
        multiple = el.multiple
        value = if multiple then [] else ""
        for option in el.querySelectorAll('option')
          continue unless option.selected
          if multiple
            value.push(option.value)
          else
            value = option.value
      else
        value = el.value

      if !params.hasOwnProperty(name)
        params[name] = []
      params[name].push(value)

    params

  @context: ->
    feed_query_string: @serializeParams(@feed_params)
    feed_params: @feed_params
    available_feed_param_names: @available_feed_param_names

  initialize: =>
    Marbles.DOM.on @el, 'submit', @handleSubmit

  handleSubmit: (e) =>
    e?.preventDefault()

    params = @constructor.serializeForm(@el)
    Marbles.history.navigate('posts' + @constructor.serializeParams(params), trigger: true)

Marbles.history.on 'handler:before', -> FilterPostsView.updateParams.apply(FilterPostsView, arguments)
