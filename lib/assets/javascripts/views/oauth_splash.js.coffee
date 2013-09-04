Marbles.Views.OAuthSplash = class OAuthSplashView extends Marbles.View
  @view_name: 'oauth_splash'
  @template_name: 'oauth_splash'

  initialize: =>
    TentAdmin.once 'oauth:failure', (msg) =>
      @render(msg: msg, error: true)

