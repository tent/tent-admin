Marbles.Views.Post = class PostView extends Marbles.View
  @template_name: '_post'
  @partial_names: ['_post_inner']
  @view_name: 'post'

  context: (model) =>
    post: model
