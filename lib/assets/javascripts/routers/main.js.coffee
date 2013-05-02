TentAdmin.Routers.main = new class MainRouter extends Marbles.Router
  routes: {
    ""        : "root"
    "profile" : "profile"
    "apps"    : "apps"
  }

  root: =>
    @navigate('/profile', { replace: true, trigger: true })

  profile: =>
    window.scrollTo(0, 0)
    new Marbles.Views.Profile container: TentAdmin.config.container

  apps: =>
    window.scrollTo(0, 0)
    new Marbles.Views.Apps container: TentAdmin.config.container
