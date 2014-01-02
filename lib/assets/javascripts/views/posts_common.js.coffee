Marbles.Views.PostsCommon = class PostsCommonView extends Marbles.View
  @getDefaultAppId: ->
    TentAdmin.config.app.id

  @getAppId: ->
    @app_id || TentAdmin.config.app.id

  @handlerBefore: (handler, fragment, params) =>
    if params.app_id
      @app_id = params.app_id
      @loadTentClient()
    else
      @app_id = @getDefaultAppId()
      @loadTentClient()

  @_loading = true
  @loadTentClient: =>
    @_loading = true
    @tent_client = null
    if @getAppId() == @getDefaultAppId()
      @_loading = false
      @trigger 'loading:complete'
      return

    @fetchApp(@getAppId())

  @fetchFailure: (msg) =>
    alert(msg)
    @_loading = false
    @trigger 'loading:complete'

  @fetchApp: (app_id) =>
    TentAdmin.Models.App.find(
      { post: app_id, entity: TentAdmin.config.meta.content.entity },
      {
        success: @fetchAppSuccess
        failure: @fetchAppFailure
      }
    )

  @fetchAppSuccess: (app) =>
    @fetchAppAuth(app, success: @fetchAppAuthSuccess, failure: @fetchAppAuthFailure)

  @fetchAppFailure: =>
    @fetchFailure('failed to fetch app')

  @fetchAppAuth: (app, options = {}) =>
    TentAdmin.Models.AppAuth.fetch({ app: app },
      success: (app_auth) =>
        options.success?(app, app_auth)

      failure: (res, xhr) =>
        options.failure?(app, res, xhr)
    )

  @fetchAppAuthSuccess: (app, app_auth) =>
    if app_auth.credentials
      @fetchAppAuthCredentialsSuccess(app, app_auth)
      return

    app_auth.fetchCredentials(
      success: => @fetchAppAuthCredentialsSuccess(app, app_auth)
      failure: @fetchAppAuthCredentialsFailure
    )

  @fetchAppAuthFailure: =>
    @fetchFailure('failed to fetch app auth')

  @fetchAppAuthCredentialsSuccess: (app, app_auth) =>
    @credentials = {
      id: app_auth.get('credentials.id')
      hawk_key: app_auth.get('credentials.content.hawk_key')
      hawk_algorithm: app_auth.get('credentials.content.hawk_algorithm')
    }

    @tent_client = new TentClient(
      TentAdmin.config.meta.content.entity,
      credentials: @credentials
      server_meta_post: TentAdmin.config.meta
    )

    @_loading = false
    @trigger 'loading:complete'

  @fetchAppAuthCredentialsFailure: =>
    @fetchFailure('failed to fetch app auth credentials')

  @withTentClient: (callback) =>
    if @_loading
      @once 'loading:complete', =>
        callback(@tent_client || TentAdmin.tent_client)
    else
      callback(@tent_client || TentAdmin.tent_client)

  context: =>
    filter_context: Marbles.Views.FilterPosts.context()
    filter_partials: Marbles.Views.FilterPosts.partials

if TentAdmin.before_ready
  Marbles.history.on 'handler:before', PostsCommonView.handlerBefore
else
  TentAdmin.on 'before:ready', ->
    Marbles.history.on 'handler:before', PostsCommonView.handlerBefore
