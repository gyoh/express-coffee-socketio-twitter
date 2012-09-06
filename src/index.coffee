express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
http = require 'http'
socketio = require 'socket.io'
moment = require 'moment'
twitter = require 'ntwitter'

app = express()
server = http.createServer app
io = socketio.listen server

server.listen 8000

# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')
# Set favicon
app.use express.favicon()
# Set View Engine
app.set 'view engine', 'jade'
# Get root_path return index view
app.get '/', (req, res) -> 
  res.render 'index'

# Config for using Twitter API
twit = new twitter
  consumer_key: 'rlNthyhOMxKjgm4Fu6ou3Q',
  consumer_secret: 'u1OkWvNONtuJT1oo9A0dmkurKe2DdsYQDkpGpANKQ4',
  access_token_key: '502914149-eVsG9cRNfWM5mw6VtPPChafLLNZVss3heiT9X0fQ',
  access_token_secret: 'vUX0OtTOyPlkjPKiHdqb6JtAHNKMfI4MmboVWA'

io.sockets.on 'connection', (socket) ->
  # Show current time
  emitNews = ->
    socket.emit 'time', moment().format 'dddd, MMMM Do YYYY, h:mm:ss a'
    
  setInterval emitNews, 1000

  socket.on 'disconnect', ->
    clearInterval emitNews

  # Show realtime tweets
  socket.on 'keyword', (keyword) ->
    twit.stream 'statuses/filter',
      track: keyword, (stream) ->
        stream.on 'data', (data) ->
          socket.emit 'tweet', data.text
        stream.on 'end', (response) ->
          # Handle a disconnection
        stream.on 'destroy', (response) ->
          # Handle a 'silent' disconnection from Twitter, no end/error event fired

# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."