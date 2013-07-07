TentAdmin.Routers.oauth = new class MainRouter extends Marbles.Router
  routes: {
    "oauth" : "oauthConfirm"
  }

  resetScrollPosition: =>
    TentAdmin.Routers.main.resetScrollPosition()

  oauthConfirm: (params) =>
    new Marbles.Views.OAuthConfirm params: params, container: TentAdmin.config.container
    @resetScrollPosition()

