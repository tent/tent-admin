Marbles.Views.AuthButton = class AuthButtonView extends Marbles.View
  @view_name: 'auth_button'

  @performSignout: (callback) =>
    new Marbles.HTTP {
      method: 'POST'
      url: TentAdmin.config.SIGNOUT_URL
      middleware: [Marbles.HTTP.Middleware.WithCredentials]
      callback: callback
    }

  @redirectToSignin: =>
    Marbles.history.navigate('/signin', trigger: true)

  @signoutRedirect: =>
    window.location.href = TentAdmin.config.SIGNOUT_REDIRECT_URL

  initialize: =>
    Marbles.DOM.on @el, 'click', @performAction

    if TentAdmin.config.authenticated
      @actionFn = @performSignout
      Marbles.DOM.setAttr(@el, 'title', Marbles.DOM.attr(@el, 'data-signout-title'))
    else
      @actionFn = @redirectToSignin
      Marbles.DOM.setAttr(@el, 'title', Marbles.DOM.attr(@el, 'data-signin-title'))

  performAction: => @actionFn()

  performSignout: (e) =>
    e?.preventDefault()

    @constructor.performSignout (res, xhr) =>
      @signoutRedirect()

  redirectToSignin: =>
    @constructor.redirectToSignin()

  signoutRedirect: =>
    @constructor.signoutRedirect()

