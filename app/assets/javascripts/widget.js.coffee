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

test_id = 1
question = 1

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

  question = 1
  showTestQuestion()

  $('.question-' + test_id).show()
  $('.a-test-' + test_id).show()

  showState('.state.test')


setTestAnswer = (index)->
  #check answer by test_id and question

  question++;
  if question <= 5
    #show next question
    showTestQuestion()
  else
    #show map
    $('.map_bg').hide()
    $('.map-' + test_id).show()
    showState('.state.map')

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


eventsTracker = new EventsTracker widget
eventsTracker.mapEventsToSignals
  'event_1':
    signal: widget.expanded
    action: 'widget expanded'
  'event_2':
    signal: widget.collapsed
    action: 'widget collapsed'

