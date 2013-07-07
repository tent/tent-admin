Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'

  constructor: ->
    super

    @basic_profile = new TentAdmin.Models.BasicProfile
    @basic_profile.on 'fetch:success', => @render()
    @basic_profile.fetch()

    @render()

  context: =>
    _.extend {}, TentAdmin.config, {
      basic_profile: @basic_profile
    }
