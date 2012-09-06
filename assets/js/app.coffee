$ ->
  socket = io.connect 'http://localhost:8000'
  socket.on 'time', (time) ->
    $('.time').text time

  $('form#search').submit ->
    $('.tweets').empty()
    socket.emit 'keyword', $('input.keyword').val()

  socket.on 'tweet', (data) ->
    tweet = $('<div class="alert alert-info">').append data
    $('.tweets').prepend tweet