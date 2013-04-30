TentAdmin.Models.BasicProfile = class BasicProfileModel extends Marbles.Model
  @model_name: 'basic_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType('https://tent.io/types/basic-profile/v0#')

  @content_fields = ['name', 'bio', 'location', 'gender', 'birthdate', 'website_url']

  constructor: ->
    @on 'change:avatar', @avatarUpdated

    super

  parseAttributes: =>
    super
    @attachmentsUpdated(@get('attachments'))

  fetch: (options = {}) =>
    xhr = null

    success = =>
      options.success?(@)
      @trigger('fetch:success', @, xhr)
    failure = =>
      options.failure?(@)
      @trigger('fetch:failure', @, xhr)

    TentAdmin.tent_client.post.list(
      params:
        entity: TentAdmin.config.current_user.entity
        types: [@constructor.post_type.toString()]
        limit: 1
      callback: (feed, xhr) =>
        return failure() unless xhr.status in [200...300]
        posts = feed.data
        return failure() unless posts.length && post = _.find(posts, (item) =>
          (new TentClient.PostType(item.type)).base == @constructor.post_type.base
        )
        @parseAttributes(post)
        success()
    )

  create: =>
    data = @toTentJSON()
    attachments = @buildAttachments()
    delete data.attachments if attachments.length

    # Ensure it hasn't been created already
    @fetch
      success: =>
        @save(data, attachments)
      failure: =>
        TentAdmin.tent_client.post.create(
          body: data
          attachments: attachments
          callback: (data, xhr) =>
            return @trigger('save:failure', data, xhr) unless xhr.status in [200...300]
            @parseAttributes(data)
            @trigger('save:success', @, xhr)
        )

  save: (data, attachments) =>
    unless @get('id')
      return @create()

    data ?= @toTentJSON()
    data.version = { parents: [{ version: @get('version.id') }] }
    attachments ?= @buildAttachments()
    delete data.attachments if attachments.length
    TentAdmin.tent_client.post.update(
      body: data
      attachments: attachments
      callback: (data, xhr) =>
        return @trigger('save:failure', data, xhr) unless xhr.status in [200...300]
        @parseAttributes(data)
        @trigger('save:success', @, xhr)
    )

  avatarUpdated: (value) =>
    if value
      reader = new FileReader
      reader.onload = (e) =>
        @set('avatar_url', e.target.result)
      reader.readAsDataURL(value)
    else
      @set('avatar_url', null)

  attachmentsUpdated: (value) =>
    return unless value && value.length
    return unless avatar_attachment = _.find value, (attachment) =>
      attachment.category == 'avatar'
    url = TentAdmin.tent_client.getNamedUrl('post_attachment',
      entity: @get('entity')
      post: @get('id')
      version: @get('version.id')
      name: avatar_attachment.name
    )
    @set('avatar_url', url)

  buildAttachments: =>
    return [] unless avatar = @get('avatar')
    [['avatar', avatar, avatar.name]]

  toTentJSON: =>
    data = {
      type: @constructor.post_type.toString()
      content: {}
    }
    data.id = id if id = @get('id')
    data.entity = entity if entity = @get('entity')
    data.mentions = mentions if mentions = @get('mentions')
    data.attachments = attachments if attachments = @get('attachments')

    for attr in @constructor.content_fields
      continue unless val = @get("content.#{attr}")
      data.content[attr] = val

    data

