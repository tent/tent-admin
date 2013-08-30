TentAdmin.Routers.auth = new class AuthRouter extends Marbles.Router
  routes: {
    "signin" : "signin"
  }

  signin: (params) =>
    params.redirect ?= TentAdmin.config.PATH_PREFIX || '/'

    if TentAdmin.config.authenticated
      return Marbles.history.navigate(params.redirect, trigger: true)

    unless TentAdmin.config.SIGNIN_URL
      return window.location.href = TentAdmin.config.SIGNOUT_REDIRECT_URL

    Marbles.Views.AppNavigationItem.disableAll()

    new Marbles.Views.Signin container: TentAdmin.config.container, redirect_url: params.redirect

