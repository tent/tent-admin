Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'

  constructor: ->
    super

    @elements = {}

    @on 'ready', @bindForm

    @basic_profile = new TentAdmin.Models.BasicProfile
    @basic_profile.on 'fetch:success', => @render()
    @basic_profile.on 'change:avatar_url', => @render()
    @basic_profile.fetch()

    @render()

  bindForm: =>
    @elements.form = Marbles.DOM.querySelector('form', @el)
    Marbles.DOM.on(@elements.form, 'submit', @saveForm)

    @elements.avatar_input = Marbles.DOM.querySelector('[type=file]', @elements.form)
    Marbles.DOM.on(@elements.avatar_input, 'change', @avatarSelected)

  avatarSelected: =>
    data = Marbles.DOM.serializeForm(@elements.form)
    avatar = data['basic_profile[avatar]']?[0]
    return unless avatar
    @basic_profile.set('avatar', avatar)

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

    @basic_profile.save()

  context: (opts = {}) =>
    _.extend {}, TentAdmin.config, {
      basic_profile: @basic_profile
    }

