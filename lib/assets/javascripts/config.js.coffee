#= require ./static_config
#= require_self

window.TentAdmin ?= {}

unless TentAdmin.config.JSON_CONFIG_URL
	throw "json_config_url is required!"

new Marbles.HTTP(
  method: 'GET'
  url: TentAdmin.config.JSON_CONFIG_URL
  middleware: [Marbles.HTTP.Middleware.WithCredentials]
  callback: (res, xhr) ->
    if xhr.status != 200
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

      return

    TentAdmin.config ?= {}
    for key, val of JSON.parse(res)
      TentAdmin.config[key] = val

    TentAdmin.config.authenticated = !!TentAdmin.config.credentials

    TentAdmin.tent_client = new TentClient(
      TentAdmin.config.meta.content.entity,
      credentials: TentAdmin.config.credentials
      server_meta_post: TentAdmin.config.meta
    )

    TentAdmin.config_ready = true
    TentAdmin.trigger?('config:ready')
)

