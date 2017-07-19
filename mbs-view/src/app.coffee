bodyParser = require 'body-parser'
methodOverride = require('method-override')
path = require 'path'
express = require 'express'
reader = require './reader'
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

root =
  if process.env.MINI_BREAKPAD_SERVER_ROOT?
    "#{process.env.MINI_BREAKPAD_SERVER_ROOT}/"
  else
    ''

app.get "/#{root}", (req, res, next) ->
  res.render 'index', title: 'Crash Reports Viewer', records: db.getAllRecords()

app.get "/#{root}view/:id", (req, res, next) ->
  db.restoreRecord req.params.id, (err, record) ->
    return next err if err?

    reader.getStackTraceFromRecord record, (err, report) ->
      return next err if err?
      fields = record.fields
      res.render 'view', {title: 'Crash Report', report, fields}
