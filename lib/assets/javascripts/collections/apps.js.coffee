TentAdmin.Collections.Apps = class AppsCollection extends Marbles.Collection
  @model: TentAdmin.Models.App
  @id_mapping_scope: ['entity']
  @collection_name: 'apps_collection'

  constructor: ->
    super
    @set('entity', TentAdmin.config.current_user.entity)

  pagination: {}

  fetch: (params = {}, options = {}) =>
    complete = (res, xhr) =>
      models = null
      if xhr.status in [200...300]
        models = @fetchSuccess(params, options, res, xhr)
        options.success?(@, models, res, xhr)
        @trigger('fetch:success', models, res, xhr, params, options)
        # success
      else
        options.failure?(@, res, xhr)
        @trigger('fetch:failure', res, xhr, params, options)
      options.complete?(@, models, res, xhr)
      @trigger('fetch:complete', models, res, xhr, params, options)

    params = _.extend {
      entity: TentAdmin.config.current_user.entity
      types: [@constructor.model.post_type]
    }, params

    TentAdmin.tent_client.post.list(params: params, callback: complete)

  fetchSuccess: (params, options, res, xhr) =>
    _.extend(@pagination, res.pages)

    data = res.data

    models = if options.append
      @appendJSON(data)
    else if options.prepend
      @prependJSON(data)
    else
      @resetJSON(data)

    models

  buildModel: (json) =>
    @constructor.model.find(
      id: json.id
      entity: json.entity
      fetch: false
    ) || new @constructor.model(json)

  resetJSON: (json, options = {}) =>
    @model_ids = []
    models = @appendJSON(json, silent: true)
    @trigger('reset', models) unless options.silent
    models

  appendJSON: (json, options = {}) =>
    return [] unless json?.length

    models = for attrs in json
      model = @buildModel(attrs)
      @model_ids.push(model.cid)
      model

    @trigger('append', models) unless options.silent

    models

  prependJSON: (json, options = {}) =>
    return [] unless json?.length

    models = for i in [json.length-1..0]
      attrs = json[i]
      model = @buildModel(attrs)
      @model_ids.unshift(model.cid)
      model

    @trigger('prepend', models) unless options.silent

    models

