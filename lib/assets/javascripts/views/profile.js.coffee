Marbles.Views.Profile = class ProfileView extends Marbles.View
  @view_name: 'profile'
  @template_name: 'profile'

  constructor: ->
    super

    @elements = {}

    @on 'ready', @bindForm

    @meta_profile = TentAdmin.Models.MetaProfile.find(entity: TentAdmin.config.meta.content.entity, fetch: false) || new TentAdmin.Models.MetaProfile
    @meta_profile.on 'change:avatar_url', => @render()
    @meta_profile.on 'save:failure', @saveFailure
    @meta_profile.on 'save:success', @saveSuccess
    @meta_profile.on 'error:avatar_size', @showError

    @render()

  enableSubmit: =>
    @elements.form_submit.disabled = false

  disableSubmit: =>
    @elements.form_submit.disabled = true

  bindForm: =>
    @elements.form = Marbles.DOM.querySelector('form', @el)
    Marbles.DOM.on(@elements.form, 'submit', @saveForm)

    @elements.form_submit = Marbles.DOM.querySelector('[type=submit]', @elements.form)
    @enableSubmit()

    @elements.avatar_input = Marbles.DOM.querySelector('[type=file]', @elements.form)
    Marbles.DOM.on(@elements.avatar_input, 'change', @avatarSelected)

  avatarSelected: =>
    data = Marbles.DOM.serializeForm(@elements.form)
    avatar = data['meta_profile[avatar]']?[0]
    return unless avatar
    @meta_profile.set('avatar', avatar)

  showError: (msg) =>
    @render(@context flash_message: { text: msg, type: 'error' })

  saveFailure: (data, xhr) =>
    @render(@context flash_message: { text: "Failed to save: #{data.error}", type: 'error' })

  saveSuccess: (meta_profile, xhr) =>
    @render(@context flash_message: { text: "Saved!", type: 'success' })

  saveForm: (e) =>
    e?.preventDefault()
    data = Marbles.DOM.serializeForm(@elements.form)
    meta_profile_data = {}
    for k, v of data
      continue unless k.match(/^meta_profile\[([^\[]+)\]$/)
      name = RegExp.$1
      continue if name == 'avatar'
      meta_profile_data[name] = v

    for key, val of meta_profile_data
      @meta_profile.set(key, val)

    @disableSubmit()
    @meta_profile.save()

  context: (additional_data = {}) =>
    _.extend { flash_message: null }, TentAdmin.config, {
      meta_profile: @meta_profile
    }, additional_data

