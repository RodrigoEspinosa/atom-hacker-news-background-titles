module.exports =
  activate: ->
    BackgroundTitlesView = require './background-titles-view'
    @backgroundTitlesView = new BackgroundTitlesView()

  deactivate: ->
    @backgroundTitlesView.destroy()
