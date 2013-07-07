TYPE_URI_REGEX = /^(.+)\/v(\d+)(?:#(.+)?)?$/
URI_TEMPLATE_REGEX = /\{([^\}]+)\}/g

class @TentClient
  @middleware = [
    Marbles.HTTP.Middleware.SerializeJSON,
    new Marbles.HTTP.Middleware.Hawk(credentials: TentAdmin.config.current_user.credentials)
  ]

  class @PostType
    constructor: (type_uri) ->
      @version = 0
      @parseUri(type_uri) if type_uri

    parseUri: (uri) =>
      if m = uri.match(TYPE_URI_REGEX)
        [m, @base, @version, @fragment] = m
        @version = parseInt(@version)

    toString: =>
      "#{@base}/v#{@version}##{@fragment || ''}"

  class @HTTP
    @MEDIA_TYPES = {
      post: "application/vnd.tent.post.v0+json"
      posts_feed: "application/vnd.tent.posts-feed.v0+json"
      mentions: "application/vnd.tent.post-mentions.v0+json"
      versions: "application/vnd.tent.post-versions.v0+json"
    }

    constructor: (@client) ->
      @servers = _.sortBy(@client.server_meta_post.content.servers, 'preference')
      @nextServer()

    nextServer: =>
      @current_server = @servers.shift()

    namedUrl: (name, params = {}) =>
      @current_server?.urls[name]?.replace URI_TEMPLATE_REGEX, =>
        param = params[RegExp.$1] || ''
        delete params[RegExp.$1]

        encodeURIComponent(param)

    runRequest: (method, _url, params, body, headers, middleware, _callback) =>
      middleware ?= []
      params = _.clone(params)

      unless _url.match(/^[a-z]+:\/\//i)
        if accept_header = @constructor.MEDIA_TYPES[_url]
          headers ?= {}
          headers.Accept ?= accept_header

        url = @namedUrl(_url, params)
      else
        url = _url

      callback = (data, xhr) =>
        console.log('request complete', method, _url, xhr.status, xhr)
        if @servers.length && !(xhr.status in [200...300]) && !(xhr.status in [400...500])
          @nextServer()
          @runRequest(method, _url, params, body, headers, _callback)
        else
          _callback?(arguments...)

      new Marbles.HTTP(
        method: method
        url: url
        params: params
        body: body
        headers: headers
        callback: callback
        middleware: [].concat(TentClient.middleware).concat(middleware)
      )

  constructor: (@entity, @options = {}) ->
    @credentials = @options.credentials
    @server_meta_post = @options.server_meta_post

    @post = {
      create: @createPost
      get: @getPost
      mentions: @getPostMentions
      versions: @getPostVersions
      list: @listPosts
    }

  runRequest: =>
    new @constructor.HTTP(@).runRequest(arguments...)

  mediaType: (name) =>
    @constructor.HTTP.MEDIA_TYPES[name]

  createPost: (args = {}) =>
    [params, headers, body, callback] = [_.clone(args.params || {}), args.headers || {}, args.body, args.callback]

    unless body.type
      throw new Error("type member of body is required! Got \"#{body.type}\"")

    headers['Content-Type'] = "#{@mediaType('post')}; type=\"#{body.type}\""

    @runRequest('POST', 'new_post', params, body, headers, null, callback)

  getPost: (args = {}) =>
    [params, headers, callback] = [_.clone(args.params || {}), args.headers || {}, args.callback]

    unless params.hasOwnProperty('entity')
      params.entity = @entity
    unless params.entity && params.post
      throw new Error("entity and post members of params are required! Got \"#{params.entity}\" and \"#{params.post}\"")

    if params.type
      headers.Accept = "#{@mediaType('post')}; type=\"#{params.type}\""
      delete params.type

    @runRequest('GET', 'post', params, null, headers, null, callback)

  getPostMentions: (args = {}) =>
    args.headers ?= {}
    args.headers.Accept ?= @mediaType('mentions')
    @getPost(args)

  getPostVersions: (args = {}) =>
    args.headers ?= {}
    args.headers.Accept ?= @mediaType('versions')
    @getPost(args)

  listPosts: (args = {}) =>
    [params, headers, callback] = [args.params, args.headers, args.callback]
    @runRequest('GET', 'posts_feed', params, null, headers, null, callback)

