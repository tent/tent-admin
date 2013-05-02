TentAdmin.Routers.main = new class MainRouter extends Marbles.Router
  routes: {
    ""        : "root"
    "profile" : "profile"
    "apps"    : "apps"
  }

  resetScrollPosition: =>
    hash_fragment = window.location.hash
    window.scrollTo(0, 0)
    window.location.hash = hash_fragment

  root: =>
    @navigate('/profile', { replace: true, trigger: true })

  profile: =>
    new Marbles.Views.Profile container: TentAdmin.config.container
    @resetScrollPosition()

  apps: =>
    new Marbles.Views.Apps container: TentAdmin.config.container
    @resetScrollPosition()
