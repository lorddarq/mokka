#= require 'widget_base'
#= require 'map'
#= require 'ltst/events'

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
    $('.map .more').hide()
    title = 'У тебя '+ pins.length + ' ' + map_title[pins.length];
    $('.map-title .title').text(title)
    $('.more .title').text(title)
    showState('.state.map')
    renderMarkers(map, pins)

autoStart = ->
  test_id = $('.calendar').attr('data-auto')
  showTest()

$('.map .again-btn').click (e)->
  e.preventDefault()
  showTest()

$('.map .calendar-btn').click (e)->
  e.preventDefault()
  showState('.state.calendar')

$('.map-title .more-btn').click (e)->
  e.preventDefault()
  $('.map .more').slideDown(500, ->
    $('.map .more .more-btn').show()
  )

$('.map .more .more-btn').click (e)->
  e.preventDefault()
  $('.map .more .more-btn').hide()
  $('.map .more').slideUp(500)

$('.menu-icon').click (e)->
  e.preventDefault()
  $('.menu').addClass('show')

$('.close-menu').click (e)->
  e.preventDefault()
  closeMenu()

$('.menu .menu-start').click (e)->
  e.preventDefault()
  autoStart()

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
shareUrl = 'http://specials.the-village.ru/mokka'
$('.share .fb').click (e)->
  e.preventDefault()
  MokkoEvents.fb_share.dispatch()
  openWindow('https://www.facebook.com/sharer.php?u=' + encodeURIComponent(shareUrl) + '&display=popup', 655, 370, true)

$('.share .vk').click (e)->
  e.preventDefault()
  MokkoEvents.vk_share.dispatch()
  openWindow('https://vk.com/share.php?url=' + shareUrl, 655, 370, true)

openWindow = (url, width, height, centered) ->
  left = if centered then (screen.width/2)-(width/2) else 0
  top = if centered then (screen.height/2)-(height/2) else 0
  window.open(url, '', 'toolbar=no, location=no, directories=no, status=no, menubar=no,
    scrollbars=no, resizable=no, copyhistory=no, width=' + width + ', height=' + height + ', left=' + left + ', top=' + top)


#  main
$('.start-btn').click (e)->
  e.preventDefault()
  autoStart()

$('.map-title .more-btn').click (e)->
  e.preventDefault()
  $('.map')

# calendar

$('.calendar .date').click (e)->
  e.preventDefault()

  test_id = $(e.target).attr('data-test')
  showTest()

# test answer click

$('a.option').click (e)->
  e.preventDefault()
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
  'event_3':
    signal: MokkoEvents.start_btn_click
    action: 'start btn click'
  'event_4':
    signal: MokkoEvents.menu_btn_click
    action: 'menu btn click'
  'event_5':
    signal: MokkoEvents.close_menu_btn_click
    action: 'close menu btn click'
  'event_6':
    signal: MokkoEvents.menu_calendar_click
    action: 'menu calendar click'
  'event_7':
    signal: MokkoEvents.menu_about_click
    action: 'menu about click'
  'event_8':
    signal: MokkoEvents.menu_rules_click
    action: 'menu rules click'
  'event_9':
    signal: MokkoEvents.calendar_date_click
    action: 'calendar date click'
  'event_10':
    signal: MokkoEvents.answer_click
    action: 'answer click'
  'event_11':
    signal: MokkoEvents.map_again_btn_click
    action: 'map again btn click'
  'event_12':
    signal: MokkoEvents.map_calendar_btn_click
    action: 'map calendar btn click'
  'event_13':
    signal: MokkoEvents.fb_share
    action: 'fb share'
  'event_14':
    signal: MokkoEvents.vk_share
    action: 'vk share'

