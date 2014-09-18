#= require signals.min
#= require jquery-min
#= require jquery_ujs
#= require jquery.ba-deparam.min
#= require jquery.cookie
#= require jquery.easing.1.3


$ = jQuery


###
  Hide console.log errors
###
unless window.console
  window.console =
    log: -> true


###
  jQuery fade animations fix
###
jQuery.fn.extend
  plFadeTo: (speed, to, easing, callback) ->
    speed = jQuery.support.opacity ? speed : 0
    opts = {
      duration: speed
      queue: false
    }
    opts.easing = easing if easing
    opts.complete = callback if callback
    this.fadeTo(opts, to)


###
  jQuery default easing
###
jQuery.extend jQuery.easing,
  'def': 'easeOutCubic'


###
  Widget
###
class Widget

  params: $.deparam(window.location.search.slice(1))
  events: {}
  defaultMainLink: '#'

  constructor: (@name, selector = '.b-widget') ->
    @namespace = @name.toLowerCase().replace(/\s/g, '_')
    @cookieTag = "#{@namespace}_tag"
    @[signal] = new signals.Signal() for signal in ['domInited', 'inited', 'loaded', 'loaderHidden']
    $ => @initialize($(selector))

  initialize: (@$widget) ->
    @setMainLink @defaultMainLink
    @setParentWindow window.parent && window.parent != window && window.parent
    @setIsLocal !!@params.local
    @checkFirstShow() unless @isLocal
    #@bindDefaultButtons()

    dfd_load = $.Deferred()
    $(window).bind 'load', =>
      dfd_load.resolve()
      @loaded.dispatch()

    $.when( dfd_load ).then =>
      $loader = $('.b-loader')
      $loader
        .removeClass('b-loader_loading')
        .animate {opacity: 0}, 1000, =>
          $loader.hide()
          @loaderHidden.dispatch()

    @domInited.dispatch()

  setParentWindow: (@parentWindow) ->
    @queryParent 'init', (data) =>
      @data = data.result
      @setMainLink(@data.link) if @data.link and !/%reference%/i.test(@data.link)
      @events = @data.events
      # set state if declared in data
      for state in @states
        @setState(state, true) if @data[state] and !@isInState(state)

      @inited.dispatch(data)

  setMainLink: (@mainLink) ->
    @$widget.find('a.main-link').attr('href', @mainLink)

  setIsLocal: (@isLocal) ->
    if @isLocal
      @$widget.addClass('b-widget_local')
      $('.b-loader').addClass('b-loader_local')
      @setState(@localState, true) if @localState

  checkFirstShow: ->
    if $.cookie(@cookieTag) == null
      $.cookie(@cookieTag, 'showed')
      @setState(@firstShowState, true) if @firstShowState

  hasStateActionButton: (buttonSelector, action) ->
    if @$widget
      @$widget.find(buttonSelector).click (e) =>
        e.preventDefault()
        @[action]?()
    else @domInited.add =>
      @hasStateActionButton(buttonSelector, action)

  # postMessage callbacks

  queryCallbacks = {}

  $(window).on 'message', (event) ->
    try
      data = event.originalEvent.data
      data = JSON.parse(data)
      if data.sign and data.lamwidget is window.name
        queryCallbacks[data.sign]?(data)
        delete queryCallbacks[data.sign] unless data.call is 'bind'

  # postMessage sending

  getCallSign = ->
    "LAMWidget #{(+ new Date()).toString()}_#{(Math.random()*10e8|0).toString()}"

  queryParent: (call, args...) =>
    return false unless @parentWindow
    if args.length && $.isFunction(args[args.length-1])
      callback = args.pop()
    message =
      'lamwidget': window.name
      'call': call
      'arguments': args
    if callback
      message.sign = getCallSign()
      queryCallbacks[message.sign] = callback
    @parentWindow.postMessage(JSON.stringify(message), '*')

  # parent window events subscription

  parentEventCallbacks = {}

  _namespaceEvent: (e) -> "#{e}.#{@namespace}"

  bindParent:(event, args...) =>
    evs = event.split(' ')
    if evs.length > 1
      @bindParent(e, args...) for e in evs
    event = @_namespaceEvent(event)
    callback = args.pop()
    return false unless callback and $.isFunction(callback)
    parentEventCallbacks[event] = callback
    dataParams = args.pop()
    dataParams = [dataParams] unless $.isArray(dataParams)
    if @parentWindow
      @queryParent 'bind', event, dataParams, args..., (data) ->
        parentEventCallbacks[data.arguments[0]]?(data.result...)
    else
      $(window).on event, (e) ->
        callbackArgs = for p in dataParams
          [object, property] = p.split('.')
          {
            'window': window
            'event': e.originalEvent
          }[object][property]
        callback callbackArgs...

  unbindParent: (event, args...) =>
    evs = event.split(' ')
    if evs.length > 1
      @unbindParent(e, args...) for e in evs
    event = @_namespaceEvent(event)
    if @parentWindow
      @queryParent 'unbind', event, args...
      delete parentEventCallbacks[event]
    else
      $(window).off event

  # states definition

  hasStates: (states) ->
    hasStateClass(state.class, state.action, state.calls, state.options) for state in states

  hasStateClass: (stateClass, actionName, calls, options = {}) ->

    # push to states list
    @states ||= []
    @states.push stateClass

    # store actionName
    @stateActions ||= {}
    @stateActions[stateClass] = actionName

    # set default state
    @defaultState ||= stateClass
    @defaultState = stateClass if options.default

    # set last state as local and as state for first show
    @localState = stateClass
    @firstShowState = stateClass

    # store state associated calls
    @stateCalls ||= {}
    @stateCalls[stateClass] = calls

    # define state signal
    @[stateClass] = new signals.Signal()

    # define state method
    @[actionName] = (silent) =>

      # query parent
      calls = @stateCalls[stateClass]
      for own call, args of calls
        args = [args] unless $.isArray(args)
        @queryParent call, args...

      # filter classes
      classes = @$widget.attr('class').split(' ')
      newClasses = []
      for c in classes
        mod = /b-widget_(\w+)/.exec(c)
        mod = mod[1] if mod
        if !mod or $.inArray(mod, @states) is -1
          newClasses.push(c)
      newClasses.push "b-widget_#{stateClass}"
      @$widget.attr 'class', newClasses.join(' ')

      # call signal
      @[stateClass].dispatch() unless silent

  setState: (className, args...) ->
    actionName = @stateActions[className]
    @[actionName]?(args...) if actionName?

  isInState: (className) ->
    @$widget.is(".b-widget_#{className}")

window.Widget = Widget


###
  Events tracking
###
class EventsTracker

  events: {}
  pixels: {}
  widget: undefined

  _eventHandlers: {}
  _firstEventIsCounted: false

  constructor: (@widget) ->
    widget.inited.add =>
      @events = @widget.events

  countEvent: (event_id, action) ->
    @_callPixel event_id
    return true unless @events
    @_checkFirstEvent()
    @_callEvent event_id
    @_callGoogleAnalytics(event_id, action) unless event_id is 'event_20'

  checkEventUrl: (event_url) ->
    event_url and not /%event\d+%/i.test(event_url)

  mapEventsToSignals: (events_map) ->
    @_trackSignal(signal, event_id) for own event_id, signal of events_map

  trackGaEvent: (category, action, label) =>
    _gaq.push ['_trackEvent', category, action, label] if _gaq?

  signalHandler = (args...) ->
    actionName = if typeof @action is 'function'
     @action(args...)
    else
      @action.toString()
    @eventsTracker.countEvent(@event_id.toString(), actionName)
  _trackSignal: (s, event_id) ->
    if s.signal
      signal = s.signal
      action = s.action
    else
      signal = s
    @_eventHandlers[event_id] = signal.add(signalHandler, {eventsTracker: this, event_id: event_id, action: action})

  _checkFirstEvent: ->
    unless @_firstEventIsCounted
      @_firstEventIsCounted = true
      @countEvent('event_20')

  _callEvent: (event_id) ->
    s = @events[event_id]
    return true unless @checkEventUrl(s)
    s = s.replace /(pr=)[^&]*/, "$1#{(Math.random()*10e8|0).toString(36)}"
    # console?.log? event_id + ": " + s
    $('<img />')
      .css({position:'absolute', top:0, left:-1000})
      .appendTo('body')
      .load(-> $(this).remove())
      .attr('src', s)

  _callPixel: (pixel_id) ->
    s = @pixels[pixel_id]
    return true unless s
    d = document
    i = d.createElement('IMG')
    b = d.body
    s = s.replace(/!\[rnd\]/, Math.round(Math.random()*9999999)) + '&tail256=' + escape(d.referrer || 'unknown')
    i.style.position = 'absolute'
    i.style.width = i.style.height = '0px'
    i.onload = i.onerror = (-> b.removeChild(i); i = b = null)
    i.src = s
    b.insertBefore(i, b.firstChild)

  _callGoogleAnalytics: (event_id, action) ->
    if action
      @trackGaEvent "#{@widget.name} named events", action
    else
      @trackGaEvent "#{@widget.name} events", 'Event Count', event_id

window.EventsTracker = EventsTracker

