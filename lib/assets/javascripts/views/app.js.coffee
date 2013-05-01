Marbles.Views.App = class AppView extends Marbles.View
  @template_name: '_app'
  @view_name: 'app'

  constructor: ->
    super

    @elements = {}

    @bindActions()

  bindActions: =>
    @elements.actions = {}
    for button_el in Marbles.DOM.querySelectorAll('[data-action]', @el)
      do (button_el) =>
        action = Marbles.DOM.attr(button_el, 'data-action')
        confirm_message = Marbles.DOM.attr(button_el, 'data-confirm')
        cid = Marbles.DOM.attr(button_el, 'data-app_cid')
        app_el = Marbles.DOM.querySelector("[data-app_cid=#{cid}]")
        @elements.actions[action] = button_el

        Marbles.DOM.on button_el, 'click', (e) =>
          e.preventDefault()
          if !confirm_message || (confirm_message && confirm(confirm_message))
            fn_name = "do#{action[0].toUpperCase()}#{action.slice(1, action.length)}"
            fn = @[fn_name]
            unless typeof fn is 'function'
              throw new Error("Expected #{@constructor.name}.prototype.#{fn_name} to be a function! Got \"#{JSON.stringify(fn)}\"")
            fn(cid, app_el, button_el)

  showError: (app_cid, message) =>
    alert_el = Marbles.DOM.querySelector("[data-alert-cid=#{app_cid}]")
    alert_el.innerText = message
    Marbles.DOM.addClass(alert_el, 'alert-error')
    Marbles.DOM.removeClass(alert_el, 'hide')

  showSuccess: (app_cid, message) =>
    alert_el = Marbles.DOM.querySelector("[data-alert-cid=#{app_cid}]")
    alert_el.innerText = message
    Marbles.DOM.addClass(alert_el, 'alert-success')
    Marbles.DOM.removeClass(alert_el, 'hide')

  ##
  # Delete App
  doRemove: (app_cid, app_el, button_el) =>
    model = TentAdmin.Models.App.find(cid: app_cid, fetch: false)
    Marbles.DOM.hide(app_el)
    model.delete(
      success: =>
        @showSuccess(app_cid, "Successfully deleted #{model.get('content.name')}!")
        app_el.remove()

        if model.get('id') == TentAdmin.config.current_user.app.id
          # we just deleted this app, wait a few seconds then signout
          setTimeout(( => window.location.reload()), 2000)

      failure: (model, res, xhr) =>
        Marbles.DOM.show(app_el)
        @showError(app_cid, "Failed to delete #{model.get('content.name')}: " + (res.error || 'Server Error'))
    )

