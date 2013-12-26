TentAdmin.Routers.main = new class MainRouter extends Marbles.Router
  routes: {
    ""        : "root"
    "profile" : "profile"
    "apps"    : "apps"
    "posts"   : "posts"
  }

  authenticationRequired: (callback) ->
    return callback() if TentAdmin.config.authenticated

    # Redirect to signin

    setImmediate ->
      TentAdmin.run(history: { silent: true })

      fragment = Marbles.history.getFragment()
      if fragment.match /^signin/
        Marbles.history.navigate(fragment, trigger: true, replace: true)
      else
        if fragment == ""
          Marbles.history.navigate("/signin", trigger: true)
        else
          Marbles.history.navigate("/signin?redirect=#{encodeURIComponent(Marbles.history.getFragment())}", trigger: true)

  resetScrollPosition: =>
    hash_fragment = window.location.hash
    window.scrollTo(0, 0)
    window.location.hash = hash_fragment unless hash_fragment == ''

  root: =>
    @navigate('/profile', { replace: true, trigger: true })

  profile: =>
    @authenticationRequired =>
      new Marbles.Views.Profile container: TentAdmin.config.container
      @resetScrollPosition()

  apps: =>
    @authenticationRequired =>
      new Marbles.Views.Apps container: TentAdmin.config.container
      @resetScrollPosition()

  posts: =>
    @authenticationRequired =>
      new Marbles.Views.Posts container: TentAdmin.config.container
      @resetScrollPosition()

