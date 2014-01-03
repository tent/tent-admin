Marbles.Views.PostsCommon = class PostsCommonView extends Marbles.View
  @getDefaultAppAuthId: ->
    TentAdmin.config.app_auth.id

  @getAppAuthId: ->
    @app_auth_id || TentAdmin.config.app_auth.id

  @handlerBefore: (handler, fragment, params) =>
    return unless TentAdmin.config.authenticated

    if params.app_auth_id
      @app_auth_id = params.app_auth_id
      @loadTentClient()
    else
      @app_auth_id = @getDefaultAppAuthId()
      @loadTentClient()

  @_loading = true
  @loadTentClient: =>
    @_loading = true
    @tent_client = null
    if @getAppAuthId() == @getDefaultAppAuthId()
      @_loading = false
      @trigger 'loading:complete'
      return

    @fetchAppAuth(@getAppAuthId())

  @fetchFailure: (msg) =>
    alert(msg)
    @_loading = false
    @trigger 'loading:complete'

  @fetchAppAuth: (app_auth_id) =>
    TentAdmin.Models.AppAuth.find(
      { post: app_auth_id, entity: TentAdmin.config.meta.content.entity },
      {
        success: @fetchAppAuthSuccess
        failure: @fetchAppAuthFailure
      }
    )

  @fetchAppAuthSuccess: (app_auth) =>
    if app_auth.credentials
      @fetchAppAuthCredentialsSuccess(app_auth)
      return

    app_auth.fetchCredentials(
      success: => @fetchAppAuthCredentialsSuccess(app_auth)
      failure: @fetchAppAuthCredentialsFailure
    )

  @fetchAppAuthFailure: =>
    @fetchFailure('failed to fetch app auth')

  @fetchAppAuthCredentialsSuccess: (app_auth) =>
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
