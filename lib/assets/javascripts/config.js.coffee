#= require ./static_config
#= require_self

window.TentAdmin ?= {}

unless TentAdmin.config.JSON_CONFIG_URL
	throw "json_config_url is required!"

new Marbles.HTTP(
  method: 'GET'
  url: TentAdmin.config.JSON_CONFIG_URL
  middleware: [{
    processRequest: (request) ->
      request.request.xmlhttp.withCredentials = true
  }]
  callback: (res, xhr) ->
    if xhr.status != 200
      return setImmediate =>
        throw "failed to load json config via GET #{TentAdmin.config.JSON_CONFIG_URL}: #{xhr.status} #{JSON.stringify(res)}"

    TentAdmin.config ?= {}
    for key, val of JSON.parse(res)
      TentAdmin.config[key] = val

    TentAdmin.tent_client = new TentClient(
      TentAdmin.config.current_user.entity,
      credentials: TentAdmin.config.current_user.credentials
      server_meta_post: TentAdmin.config.current_user.server_meta_post
    )

    TentAdmin.config_ready = true
    TentAdmin.trigger?('config:ready')
)

