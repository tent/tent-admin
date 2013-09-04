TentAdmin.Routers.oauth = new class MainRouter extends Marbles.Router
  routes: {
    "oauth" : "oauthConfirm"
  }

  authenticationRequired: (callback) ->
    TentAdmin.Routers.main.authenticationRequired(callback)

  resetScrollPosition: =>
    TentAdmin.Routers.main.resetScrollPosition()

  oauthConfirm: (params) =>
    @authenticationRequired =>
      new Marbles.Views.OAuthConfirm params: params, container: TentAdmin.config.container
      @resetScrollPosition()

