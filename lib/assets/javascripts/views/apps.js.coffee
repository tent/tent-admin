Marbles.Views.Apps = class AppsView extends Marbles.View
  @template_name: 'apps'

  constructor: ->
    super

    @collection = TentAdmin.Collections.Apps.find(entity: TentAdmin.config.current_user.entity) || new TentAdmin.Collections.Apps
    @collection.on 'reset', => @render()
    @collection.fetch()

    @render()

  context: =>
    _.extend {}, TentAdmin.config, {
      apps: @collection.models()
    }

