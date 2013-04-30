Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'

  constructor: ->
    super

    @elements = {}

    @on 'ready', @bindForm

    @basic_profile = TentAdmin.Models.BasicProfile.find(entity: TentAdmin.config.current_user.entity, fetch: false) || new TentAdmin.Models.BasicProfile
    @basic_profile.on 'fetch:success', => @render()
    @basic_profile.on 'change:avatar_url', => @render()
    @basic_profile.on 'save:failure', @saveFailure
    @basic_profile.on 'save:success', @saveSuccess
    @basic_profile.fetch()

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
    avatar = data['basic_profile[avatar]']?[0]
    return unless avatar
    @basic_profile.set('avatar', avatar)

  saveFailure: (data, xhr) =>
    @render(@context flash_message: { text: "Failed to save: #{data.error}", type: 'error' })

  saveSuccess: (basic_profile, xhr) =>
    @render(@context flash_message: { text: "Saved!", type: 'success' })

  saveForm: (e) =>
    e?.preventDefault()
    data = Marbles.DOM.serializeForm(@elements.form)
    basic_profile_data = _.inject(data, ((memo, val, key) =>
      return memo unless val
      return memo unless key.match(/^basic_profile\[([^\[]+)\]$/)
      name = RegExp.$1
      return memo if name == 'avatar'
      memo[name] = val
      memo
    ), {})

    for key, val of basic_profile_data
      @basic_profile.set("content.#{key}", val)

    @disableSubmit()
    @basic_profile.save()

  context: (additional_data = {}) =>
    _.extend { flash_message: null }, TentAdmin.config, {
      basic_profile: @basic_profile
    }, additional_data

