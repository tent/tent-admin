Marbles.Views.EditableMultiselect = class EditableMultiselectView extends Marbles.View
  @template_name: 'editable_multiselect'
  @view_name: 'editable_multiselect'

  initialize: =>
    @render()

  addValue: (e) =>
    e?.preventDefault()

    value = @input_el.value
    @input_el.value = ""

    option_el = document.createElement('option')
    option_el.value = value
    option_el.selected = true
    Marbles.DOM.setInnerText(option_el, value)
    @el.appendChild(option_el)

  render: (context = @context()) =>
    html = @renderHTML(context)

    fragment = document.createDocumentFragment()
    Marbles.DOM.appendHTML(fragment, html)

    @input_el = fragment.querySelector('input[type=text]')
    @button_el = fragment.querySelector('button')

    Marbles.DOM.insertBefore(fragment, @el)

    Marbles.DOM.on @button_el, 'click', @addValue

    @trigger 'ready'
