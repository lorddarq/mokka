#= require 'widget_base'
#= require 'map'
#= require 'ltst/events'

widget = new Widget "Opel Mokka"

widget.hasStateClass 'collapsed', 'collapse', { height: 90 }
widget.hasStateClass 'expanded', 'expand', { height: 250 }

# widget.defaultState = 'collapsed'
# widget.firstShowState = 'expanded'
# widget.localState = 'expanded'

widget.hasStateActionButton '.b-open-btn', 'expand'
widget.hasStateActionButton '.expand-link', 'expand'
widget.hasStateActionButton '.b-view_collapsed', 'expand'
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

map_title_phone = ['правильных<br />ответов',
             'правильный<br /> ответ',
             'правильных<br /> ответа',
             'правильных<br /> ответа',
             'правильных<br /> ответа',
             'правильных<br /> ответов']

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
  $('.question-' + test_id).html($('.question-' + test_id).attr('data-text-' + question))

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
    pins.push({ lng: answer.attr('data-lng'), lat: answer.attr('data-lat'), time: answer.attr('data-time') })

  question++;
  if question <= 5
    #show next question
    showTestQuestion()
  else
    #show map
    $('.map .more').hide()
    test_date = $('.calendar .date_'+test_id).find('.num').text() + ' ' + $('.calendar .date_'+test_id).find('.mon').text()
    title = 'У тебя '+ pins.length + ' ' + map_title[pins.length];
    content_more = 'Ищи здесь Opel Mokka Moscow Edition ' + test_date + '<br/> и выкладывай фото с ним в Instagram с #mokkagoorange. <br /> Первые десять нашедших получат приглашения в интересные места Москвы, рекомендованные The Village, а все авторы фотографий — дизайнерские наклейки <br /> и шанс выиграть главный приз — годовой абонемент на парковку в центре.'

    if appMode == 'phone'
      title = 'У тебя<br />'+ pins.length + ' ' + map_title_phone[pins.length];
      content_more = 'Ищи здесь Opel Mokka Moscow Edition ' + test_date + ' и выкладывай фото с ним в Instagram с #mokkagoorange. Первые десять нашедших получат приглашения<br>в интересные места Москвы, рекомендованные The Village,<br>а все авторы фотографий — дизайнерские наклейки и шанс выиграть главный приз — годовой абонемент на парковку в центре.'

    $('.map-title .title').html(title)
    $('.more .title').html(title)

    $('.more .more-content').html(content_more)

    showState('.state.map')

    if !map
      map = showMap([]);
    renderMarkers(map, pins)

autoStart = ->
  test_id = $('.calendar').attr('data-auto')
  showTest()

$('.map .again-btn').click (e)->
  e.preventDefault()
  MokkoEvents.map_again_btn_click.dispatch()
  showTest()

$('.map .calendar-btn').click (e)->
  e.preventDefault()
  MokkoEvents.map_calendar_btn_click.dispatch()
  showState('.state.calendar')

$('.map-title .more-btn').click (e)->
  e.preventDefault()
  MokkoEvents.map_more_click.dispatch()
  $('.map .more').slideDown(500, ->
    $('.map .more .more-btn').show()
  )

$('.map .more .more-btn').click (e)->
  e.preventDefault()
  $('.map .more .more-btn').hide()
  $('.map .more').slideUp(500)

$('.menu-icon').click (e)->
  e.preventDefault()
  MokkoEvents.menu_btn_click.dispatch()
  $('.menu').addClass('show')

$('.close-menu').click (e)->
  e.preventDefault()
  MokkoEvents.close_menu_btn_click.dispatch()
  closeMenu()

$('.menu .menu-start').click (e)->
  e.preventDefault()
  MokkoEvents.menu_start_click.dispatch()
  autoStart()

$('.menu .menu-calendar').click (e)->
  e.preventDefault()
  MokkoEvents.menu_calendar_click.dispatch()
  showState('.state.calendar')

$('.menu .menu-about').click (e)->
  e.preventDefault()
  MokkoEvents.menu_about_click.dispatch()
  showState('.state.about')


$('.menu .menu-rules').click (e)->
  e.preventDefault()
  MokkoEvents.menu_rules_click.dispatch()
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
  MokkoEvents.start_btn_click.dispatch()
  autoStart()

$('.map-title .more-btn').click (e)->
  e.preventDefault()
  $('.map')

# calendar

$('.calendar .date').click (e)->
  e.preventDefault()
  MokkoEvents.calendar_date_click.dispatch()
  test_id = $(e.target).attr('data-test')
  showTest()

# test answer click

$('a.option').click (e)->
  e.preventDefault()
  MokkoEvents.answer_click.dispatch()
  setTestAnswer($(e.target).attr('data-index'))

if appMode == 'phone'
  $('.rules .nav .item').click (e)->
    e.preventDefault()
    index = $(e.target).attr('data-index')
#    $('.rules .img .active').hide('fast')
    $('.rules .img .active').removeClass('active')
    $('.rules .img .r_' + index).addClass('active')

    $('.rules .nav .active').removeClass('active')
    $('.rules .nav .item_' + index).addClass('active')

$ ->
  if widget.isLocal
    window.parent.postMessage('widget_inited', '*')

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
  'event_15':
    signal: MokkoEvents.menu_start_click
    action: 'menu start click'
  'event_16':
    signal: MokkoEvents.map_more_click
    action: 'map more click'
