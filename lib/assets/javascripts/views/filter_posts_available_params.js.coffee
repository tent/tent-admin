Marbles.Views.FilterPostsAvailableParams = class FilterPostsAvailableParamsView extends Marbles.View
  @template_name: 'filter_posts/available_params'
  @view_name: 'filter_posts_available_params'

  @context: ->
    Marbles.Views.FilterPosts.context()

  initialize: (options) ->
    @select_el = @el.querySelector('select')
    @button_el = @el.querySelector('button')

    Marbles.DOM.on(@button_el, 'click', @addField)

  addField: (e) =>
    e?.preventDefault()

    name = @select_el.value

    template = Marbles.Views.FilterPosts.partials["filter_posts/#{name}"]
    throw Error("Template not found: filter_posts/#{name}") unless template

    Marbles.DOM.appendHTML(@el, template.render({ name: name, value: null }))

    unless name == 'mentions'
      option = @select_el.querySelector("[value=#{name}]")
      Marbles.DOM.removeNode(option)

      @select_el.value = ""

    @bindViews()
