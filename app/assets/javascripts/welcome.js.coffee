# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(document).on "click", "#pedirLibro .close-reveal-modal", ->
    $('#pedirLibro').foundation('reveal', 'close')
    true

  $('#pedir').click ->
    $('#pedirLibro').foundation('reveal', 'open')
    false