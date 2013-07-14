Marbles.Views.OAuthConfirm = class OAuthConfirmView extends Marbles.View
  @view_name: 'oauth_confirm'
  @template_name: 'oauth_confirm'

  initialize: (options = {}) =>
    @params = options.params

    @elements = {}

    splash_view = new Marbles.Views.OAuthSplash container: @container
    splash_view.render()

    @on 'ready', @bindForm

    TentAdmin.Models.App.find(
      { post: @params.client_id, entity: TentAdmin.config.meta.entity },
      success: (app, xhr) =>
        @app_cid = app.cid

        TentAdmin.Models.AppAuth.fetch({ app: app },
          success: (app_auth) =>
            auth_types = {
              read: (app_auth.get('content.types.read') || []).sort()
              write: (app_auth.get('content.types.write') || []).sort()
            }
            auth_scopes = (app_auth.get('content.scopes') || []).sort()

            app_types = {
              read: (app.get('content.types.read') || []).sort()
              write: (app.get('content.types.write') || []).sort()
            }
            app_scopes = (app.get('content.scopes') || []).sort()

            if auth_types == app_types && auth_scopes == app_scopes
              @handleSuccess(app_auth.get('credentials.content.hawk_key'))
            else
              added_read_types = _.difference(app_types.read, auth_types.read)
              added_write_types = _.difference(app_types.write, auth_types.write)
              added_scopes = _.difference(app_scopes, auth_scopes)

              if added_read_types.length || added_write_types.length || added_scopes.length
                @render(@context(app))
              else
                app_auth.update({
                  content:
                    types:
                      read: app_types.read
                      write: app_types.write
                    scopes: app_scopes
                },
                  success: (app_auth, xhr) =>
                    @handleSuccess(app_auth.get('credentials.content.hawk_key'))

                  failure: (res, xhr) =>
                    @render(@context(app))
                )

          failure: (res, xhr) =>
            @render(@context(app))
        )

      failure: (res, xhr) =>
        console.error("Failed to lookup app!", xhr.status, res, xhr)
    )

  bindForm: =>
    @elements.form = Marbles.DOM.querySelector('form', @el)
    return unless @elements.form

    @elements.form_deny = Marbles.DOM.querySelector('[data-access=deny]', @elements.form)
    Marbles.DOM.on @elements.form, 'submit', @handleFormSubmit
    Marbles.DOM.on @elements.form_deny, 'click', @handleUserAbort

  handleFormSubmit: (e) =>
    e?.preventDefault()
    data = Marbles.DOM.serializeForm(@elements.form, expand_nested: true)

    read_types = []
    for type, val of data.read_types || {}
      read_types.push(type)

    write_types = []
    for type, val of data.write_types || {}
      write_types.push(type)

    scopes = []
    for scope, val of data.scopes || {}
      scopes.push(scope)

    data = {
      content:
        types:
          read: read_types
          write: write_types
        scopes: scopes
    }

    TentAdmin.Models.AppAuth.updateOrCreate(
      { app: @getApp(), data: data },
      success: (app_auth, xhr) =>
        @handleSuccess(app_auth.get('credentials.content.hawk_key'))

      failure: (res, xhr) =>
        console.error("Failed to update/create app-auth", xhr.status, res, xhr)
    )

  handleSuccess: (code) =>
    params = "code=#{encodeURIComponent code}"
    params += "&state=#{encodeURIComponent @params.state}" if @params.state

    @handleRedirect(params)

  handleUserAbort: (e) =>
    e?.preventDefault()

    params = "error=user_abort"
    params += "&state=#{encodeURIComponent @params.state}" if @params.state

    @handleRedirect(params)

  handleRedirect: (params) =>
    redirect_uri = @getApp()?.get('content.redirect_uri')

    if redirect_uri
      if redirect_uri.indexOf("?") != -1
        redirect_uri += "&#{params}"
      else
        redirect_uri += "?#{params}"

      window.location.href = redirect_uri
    else
      console.error("redirect_uri not set", params)

  getApp: =>
    TentAdmin.Models.App.find(cid: @app_cid, fetch: false)

  context: (app = @getApp()) =>
    app: app

