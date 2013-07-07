TentAdmin.Models.App = class AppModel extends Marbles.Model
  @model_name: 'app'
  @id_mapping_scope: ['id', 'entity']

  @post_type: new TentClient.PostType('https://tent.io/types/app/v0#')

  @fetch: (params = {}, options = {}) ->
    callbackFn = (res, xhr) =>
      if xhr.status == 200
        model = new @(res.post)
        options.success?(model, xhr)
      else
        options.failure?(res, xhr)
      options.complete?(res, xhr)

    TentAdmin.tent_client.post.get(params: params, callback: callbackFn)

  delete: (options = {}) =>
    success = (xhr) =>
      options.success?(@, xhr)
      @detach()

    failure = (res, xhr) =>
      options.failure?(@, res, xhr)

    complete = (data, xhr) =>
      if xhr.status in [200...300]
        success(xhr)
      else
        failure(data, xhr)

    TentAdmin.tent_client.post.delete(
      params:
        entity: @get('entity')
        post: @get('id')
      callback: complete
    )

