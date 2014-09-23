#= require 'widget_base'
#= require 'map'

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

test_id = 1
question = 1
pins = []

map_title = ['правильных ответов',
             'правильный ответ',
             'правильных ответа',
             'правильных ответа',
             'правильных ответа',
             'правильных ответов']

closeMenu = ->
  $('.menu').removeClass('show')

showState = (sel)->
  closeMenu()
  $('.state').hide()
  $(sel).show()


showTestQuestion = ()->

  #bg
  $('.test-bg div').hide()
  $('.test-bg .test-bg-' + question).show()

  #показываем вопрос
  $('.question-' + test_id).text($('.question-' + test_id).attr('data-text-' + question))

  #обновляем ответы
  $('.answer').hide()
  $('.answer-' + question).show()

  #обновляем прогресс бар
  $('.test-nav').hide()
  $('.test-nav-' + question).show()


showTest = ()->
  #hide old values
  $('.questions div').hide()
  $('.answers .a-test').hide()
  $('.a-test .answer').hide()

  pins = []
  question = 1
  showTestQuestion()

  $('.question-' + test_id).show()
  $('.a-test-' + test_id).show()

  showState('.state.test')


setTestAnswer = (index)->
  #check answer by test_id and question
  console.log(test_id, question)


  answer = $('.a-test-'+test_id+' .answer-'+question)

  if answer.attr('data-check') == index
    console.log(answer.attr('data-check'),index, answer.attr('data-check') == index)
    pins.push({ lng: answer.attr('data-lng'), lat: answer.attr('data-lat') })

  question++;
  if question <= 5
    #show next question
    showTestQuestion()
  else
    #show map
    console.log(pins.length, map_title[pins.length])
    $('.map-title').text('У тебя '+ pins.length + ' ' + map_title[pins.length])
    showState('.state.map')
    renderMarkers(map, pins)

$('.map .again-btn').click (e)->
  e.preventDefault()
  showTest()

$('.map .calendar-btn').click (e)->
  e.preventDefault()
  showState('.state.calendar')

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
  console.log(e.target)
  test_id = $(e.target).attr('data-test')
  showTest()

# test answer click

$('a.option').click (e)->
  setTestAnswer($(e.target).attr('data-index'))

if !map
  map = showMap([]);


eventsTracker = new EventsTracker widget
eventsTracker.mapEventsToSignals
  'event_1':
    signal: widget.expanded
    action: 'widget expanded'
  'event_2':
    signal: widget.collapsed
    action: 'widget collapsed'

