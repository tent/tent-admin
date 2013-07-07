#= require hawk

Marbles.HTTP.Middleware.Hawk = class HawkMiddleware
  constructor: (options = {}) ->
    options = _.clone(options)
    unless options.credentials
      throw new Error("HawkMiddleware: credentials member of options is required!")

    @credentials = {
      id: options.credentials.id,
      key: options.credentials.hawk_key,
      algorithm: options.credentials.hawk_algorithm
    }

    delete options.credentials
    @options = options

  processRequest: (http) ->
    header = hawk.client.header(http.method, http.url, _.extend({
        credentials: @credentials
        payload: http.body
      }, @options)
    ).field
    return unless header

    http.setHeader('Authorization', header)

  processResponse: (http, xhr) ->

