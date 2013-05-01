Marbles.Views.Apps = class AppsView extends Marbles.View
  @template_name: 'apps'
  @partial_names: ['_app']
  @view_name: 'apps'

  constructor: ->
    super

    @on 'ready', @initAutoPaginate

    @pagination_frozen = true

    @collection = TentAdmin.Collections.Apps.find(entity: TentAdmin.config.current_user.entity) || new TentAdmin.Collections.Apps
    @collection.on 'reset', => @render()
    @collection.fetch()

    @render()

  context: =>
    apps: @collection.models()


