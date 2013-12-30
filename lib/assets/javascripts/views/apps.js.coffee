Marbles.Views.Apps = class AppsView extends Marbles.View
  @template_name: 'apps'
  @partial_names: ['_app']
  @view_name: 'apps'

  detach: =>
    for cid in @collection.model_ids
      Marbles.Model.detach(cid)
    @collection.detach()
    super

  constructor: ->
    super

    @on 'ready', @initAutoPaginate

    @pagination_frozen = true

    @collection = TentAdmin.Collections.Apps.find(entity: TentAdmin.config.meta.content.entity) || new TentAdmin.Collections.Apps

    _render_set_immediate = null

    @collection.on 'reset', =>
      clearImmediate(_render_set_immediate)

      _render_set_immediate = setImmediate =>
        # defer until model.auth is set
        # (see fetchSuccess() method of apps collection)

        @render()

    @collection.on 'append', (models) =>
      clearImmediate(_render_set_immediate)

      _render_set_immediate = setImmediate =>
        # defer until model.auth is set
        # (see fetchSuccess() method of apps collection)

        @appendRender(models)

    @collection.fetch({
      max_refs: 2
    }, complete: (=> @pagination_frozen = false ))

    @render()

  context: =>
    apps: @collection.models()
    protected_apps: TentAdmin.config.protected_apps || []

  appendRender: (models) =>
    ul = Marbles.DOM.querySelector('ul.apps', @el)
    template = @constructor.partials._app
    fragment = document.createDocumentFragment()

    for model in models
      Marbles.DOM.appendHTML(fragment, template.render(
        app: model
        auth: model.auth
        protected_apps: TentAdmin.config.protected_apps || []
      ))

    @bindViews(fragment)
    ul.appendChild(fragment)

  nextPage: =>
    @pagination_frozen = true
    if @collection.fetchNext(
      complete: => @pagination_frozen = false
    ) is false
      @last_page = true

  initAutoPaginate: =>
    TentAdmin.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_post = Marbles.DOM.querySelector('li.app:last-of-type', @el)
    return unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + Marbles.DOM.windowHeight()

    if last_post_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

