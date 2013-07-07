TentAdmin.Models.AppAuth = class AppAuthModel extends Marbles.Model
  @model_name: 'app_auth'
  @id_mapping_scope: ['id', 'entity']

  @post_type: new TentClient.PostType('https://tent.io/types/app-auth/v0#')

  @fetch: (params, options = {}) ->
    unless app = params.app
      throw "params.app not given"

    callbackFn = (res, xhr) =>
      if xhr.status == 200 && res.posts.length && res.refs.length
        post = res.posts[0]
        app_auth = @find(id: post.id, entity: post.entity, fetch: false) || new @(post)

        credentials = null
        for ref in res.refs
          continue unless (new TentClient.PostType ref.type).base == 'https://tent.io/types/credentials'
          credentials = ref
          break
        app_auth.set("credentials", credentials) if credentials

        options.success?(app_auth, xhr)
      else
        options.failure?(res, xhr)

      options.complete?(res, xhr)

    TentAdmin.tent_client.post.list(
      params:
        types: @post_type.toString()
        mentions: "#{app.get('entity')} #{app.get('id')}"
        max_refs: 10
        limit: 1

      callback: callbackFn
    )

  @updateOrCreate: (params, options = {}) ->
    data = params.data

    unless app = params.app
      throw "params.app not given"

    data.mentions ?= [
      { post: app.get('id'), type: app.get('type') }
    ]

    data.refs ?= [
      { post: app.get('id'), type: app.get('type') }
    ]

    successFn = (app_auth, xhr) =>
      app_auth.update(data, options)

    failureFn = (res, xhr) =>
      unless xhr.status == 200
        options.failure?(res, xhr)
        options.complete?(res, xhr)
        return

      @create(data, options)

    @fetch(params,
      success: successFn
      failure: failureFn
    )

  @create: (data, options = {}) =>
    callbackFn = (res, xhr) =>
      if xhr.status == 200
        post = res.post
        app_auth = @find(id: post.id, entity: post.entity, fetch: false) || new @(post)

        link_header = xhr.getResponseHeader('Link')
        links = Marbles.HTTP.LinkHeader.parse(link_header || "")

        link = null
        for l in links
          continue unless l.rel == "https://tent.io/rels/credentials"
          link = l
          break

        unless link
          return options.failure?({error: "Credentials link missing"}, xhr)

        app_auth.fetchCredentialsFromLink(link, options)
      else
        options.failure?(res, xhr)
        options.complete?(res, xhr)

    TentAdmin.tent_client.post.create(
      body: _.extend({
        type: @post_type.toString()
      }, data)

      callback: callbackFn
    )

  update: (data, options = {}) =>
    callbackFn = (res, xhr) =>
      if xhr.status == 200
        post = res.post
        @parseAttributes(post)

        @fetchCredentials(options)
      else
        options.failure?(res, xhr)
        options.complete?(res, xhr)

    data = _.extend(@toJSON(), data, {
      version: {
        parents: [{ version: @get('version.id') }]
      }
    })
    data.refs = @get('refs')
    data.mentions = @get('mentions')

    TentAdmin.tent_client.post.update(
      params:
        post: @get('id')
        entity: @get('entity')
      body: data

      callback: callbackFn
    )

  fetchCredentials: (options = {}) =>
    callbackFn = (res, xhr) =>
      if xhr.status == 200
        refs = res.refs
        post = null

        for ref in refs
          continue unless (new TentClient.PostType(ref.type)).base == 'https://tent.io/types/credentials'
          post = ref
          break

        if post
          @set("credentials", post)
          options.success?(@, xhr)
        else
          options.failure?(res, xhr)
      else
        options.failure?(res, xhr)

      options.complete?(res, xhr)

    TentAdmin.tent_client.post.get(
      params:
        post: @get('id')
        entity: @get('entity')
        max_refs: 10
      callback: callbackFn
    )

  fetchCredentialsFromLink: (link, options = {}) =>
    callbackFn = (res, xhr) =>
      if xhr.status == 200
        post = res.post
        @set("credentials", post)

        options.success?(@, xhr)
      else
        options.failure?(res, xhr)

      options.complete?(res, xhr)

    new Marbles.HTTP(
      method: 'GET'
      url: link.href
      middleware: [
        Marbles.HTTP.Middleware.SerializeJSON
      ]
      callback: callbackFn
    )

  toJSON: =>
    attrs = {}
    for k in (@fields || [])
      continue if k == 'credentials'
      attrs[k] = @[k]
    attrs

