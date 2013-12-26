#= require ./posts_collection

TentAdmin.Collections.Apps = class AppsCollection extends TentAdmin.Collections.PostsCollection
  @model: TentAdmin.Models.App
  @collection_name: 'apps_collection'

  fetch: (params = {}, options = {}) =>
    params = _.extend {
      entity: TentAdmin.config.meta.content.entity
      types: [@constructor.model.post_type]
    }, params

    super(params, options)

  fetchSuccess: (params, options, res, xhr) =>
    # reject any apps that don't ref an app auth
    res.posts = _.reject res.posts, (_post) ->
      !_post.refs?.length || !_.find(_post.refs, ((_r) -> _r.type == TentAdmin.Models.AppAuth.post_type.toString()))

    models = super(params, options, res, xhr)

    # get app-auth ref for each app model
    for app in models
      auth_ref = _.find app.refs, (_ref) ->
        _ref.type == TentAdmin.Models.AppAuth.post_type.toString()

      auth_json = _.find res.refs, (_post) ->
        _post.id == auth_ref.post

      app.auth = TentAdmin.Models.AppAuth.find(id: auth_json.id, entity: auth_json.entity, fetch: false)
      app.auth ?= new TentAdmin.Models.AppAuth(auth_json)

    models

