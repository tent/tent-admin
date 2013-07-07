TentAdmin.Models.BasicProfile = class BasicProfileModel extends Marbles.Model
  @model_name: 'basic_profile'
  @id_mapping_scope: ['id', 'entity']

  @post_type: new TentClient.PostType('https://tent.io/types/basic-profile/v0#')

  fetch: =>
    TentAdmin.tent_client.post.list(
      params:
        types: [@constructor.post_type.toString()]
      callback: (feed, xhr) =>
        return unless xhr.status in [200...300]
        posts = feed.data
        return @create() unless posts.length && post = _.find(posts, (item) =>
          (new TentClient.PostType(item.type)).base == @constructor.post_type.base
        )
        @parseAttributes(post)
    )

  create: =>
    TentAdmin.tent_client.post.create(
      body: {
        type: @constructor.post_type.toString(),
        content: {}
      }
      callback: (data, xhr) =>
        return unless xhr.status in [200...300]
        console.log('create success', data)
        @parseAttributes(data)
    )
