#= require 'widget_base'


widget = new Widget "Opel Mokka"

widget.hasStateClass 'collapsed', 'collapse', { height: 90 }
widget.hasStateClass 'expanded', 'expanded', { height: 250 }

# widget.defaultState = 'collapsed'
# widget.firstShowState = 'expanded'
# widget.localState = 'expanded'

widget.hasStateActionButton '.b-open-btn', 'expand'
widget.hasStateActionButton '.expand-link', 'expand'
widget.hasStateActionButton '.b-close-btn', 'collapse'

window.widget = widget

closeMenu = ->
  $('.menu').removeClass('show')

showState = (sel)->
  closeMenu()
  $('.state').hide()
  $(sel).show()


$('.menu-icon').click (e)->
  e.preventDefault()
  $('.menu').addClass('show')

$('.close-menu').click (e)->
  e.preventDefault()
  closeMenu()

#$('.menu .menu-start').click (e)->
#  e.preventDefault()
#  closeMenu()

$('.menu .menu-calendar').click (e)->
  e.preventDefault()
  showState('.state.calendar')


$('.menu .menu-about').click (e)->
  e.preventDefault()
  showState('.state.about')


$('.menu .menu-rules').click (e)->
  e.preventDefault()
  showState('.state.rules')

# share

$('.share .fb').click (e)->
  e.preventDefault()

$('.share .vk').click (e)->
  e.preventDefault()

#  main
$('.start-btn').click (e)->
  e.preventDefault()
  showState('.state.calendar')

# calendar

$('.calendar .date').click (e)->
  id = $(e.target).attr('data-test')
  $('.question').text($('.question').attr('data-text-'+id))
  $('.answers div').hide()
  $('.answers .a-test-' + id).show()
  $('.calendar').show()

eventsTracker = new EventsTracker widget
eventsTracker.mapEventsToSignals
  'event_1':
    signal: widget.expanded
    action: 'widget expanded'
  'event_2':
    signal: widget.collapsed
    action: 'widget collapsed'

