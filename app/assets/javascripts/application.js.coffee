# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs

receiveMessage = (event)->
  console.log event
  if event.data == "widget_inited"
    $('.widget iframe').contents().find('.b-view_expanded').css('top', '1px')
    $('.widget iframe').contents().find('.b-widget_expanded').css('height', '250px')
    $('.widget iframe').contents().find('.b-widget').css('border', 'none')

window.addEventListener("message", receiveMessage, false);

