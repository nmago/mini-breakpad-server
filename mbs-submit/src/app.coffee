bodyParser = require 'body-parser'
methodOverride = require('method-override')
path = require 'path'
express = require 'express'
saver = require './saver'
Database = require './database'

app = express()

db = new Database
db.on 'load', ->
  port = process.env.MINI_BREAKPAD_SERVER_PORT ? 1127
  app.listen port
  console.log "Listening on port #{port}"

app.set 'views', path.resolve(__dirname, '..', 'views')
app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use bodyParser.urlencoded({extended: true})
app.use methodOverride()
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/post', (req, res, next) ->
  saver.saveRequest req, db, (err, filename) ->
    return next err if err?

    console.log 'saved', filename
    res.send path.basename(filename)
    res.end()

root =
  if process.env.MINI_BREAKPAD_SERVER_ROOT?
    "#{process.env.MINI_BREAKPAD_SERVER_ROOT}/"
  else
    ''

app.get "/#{root}", (req, res, next) ->
  res.render 'index', title: 'Crash Reports Submitter', records: db.getAllRecords()
