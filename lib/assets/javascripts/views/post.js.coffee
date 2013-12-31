Marbles.Views.Post = class PostView extends Marbles.View
  @template_name: '_post'
  @partial_names: ['_post_inner']
  @view_name: 'post'

  detach: =>
    @detachChildViews()
    super

  initialize: =>
    @post_cid = Marbles.DOM.attr(@el, 'data-post_cid')

  model: =>
    Marbles.Model.find(cid: @post_cid)

  context: (model = @model()) =>
    post: model

  jsonContext: (model = @model()) =>
    post: model
    post_json_string: JSON.stringify(model.toJSON(), undefined, 2)

  renderJSON: =>
    @render(@jsonContext())
