TentAdmin.Models.MetaProfile = class  MetaProfileModel extends Marbles.Model
  @model_name: 'meta_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType('https://tent.io/types/meta/v0#')

  @content_fields = ['name', 'bio', 'location', 'website']

  constructor: ->
    @on 'change:avatar', @avatarUpdated

    super

  parseAttributes: (attrs) =>
    @server_meta ?= new Marbles.Object
    for k,v of attrs
      @server_meta.set(k, v)

    attrs = _.extend({ entity: @server_meta.get('content.entity') }, @server_meta.get('content.profile') || {})
    super(attrs)

    if digest = @server_meta.get('attachments')?[0]?.digest
      @set('avatar_digest', digest)

    if @get('avatar_digest')
      @set('avatar_url', TentAdmin.tent_client.getNamedUrl('attachment', entity: @get('entity'), digest: @get('avatar_digest')))
    else
      @set('avatar_url', TentAdmin.config.DEFAULT_AVATAR_URL)

  avatarUpdated: (value) =>
    if value
      if value.size > 1000000
        return @trigger('error:avatar_size', "Avatar must be 1MB or less. The one you have selected is #{TentAdmin.Helpers.formatStorageAmount(value.size)}.")

      reader = new FileReader
      reader.onload = (e) =>
        @set('avatar_url', e.target.result)
      reader.readAsDataURL(value)
    else
      @set('avatar_url', null)

  buildAttachments: =>
    return [] unless avatar = @get('avatar')
    [['avatar', avatar, avatar.name]]

  save: (data, attachments) =>
    data ?= @toTentJSON()
    data.version = { parents: [{ version: @server_meta.get('version.id'), post: @server_meta.get('id') }] }
    attachments ?= @buildAttachments()
    delete data.attachments if attachments.length
    TentAdmin.tent_client.post.update(
      body: data
      attachments: attachments
      callback: (data, xhr) =>
        return @trigger('save:failure', data, xhr) unless xhr.status == 200
        @parseAttributes(data.post)
        @trigger('save:success', @, xhr)
    )

  toTentJSON: =>
    data = {}

    for attr in @constructor.content_fields
      continue unless val = @get(attr)
      data[attr] = val

    @server_meta.set('content.profile', data)
    @server_meta

TentAdmin.once 'config:ready', =>
  server_meta_post = TentAdmin.config.meta
  TentAdmin.meta_profile = new MetaProfileModel(server_meta_post)
