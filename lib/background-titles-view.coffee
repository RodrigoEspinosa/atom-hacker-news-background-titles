_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'
Titles = require './titles'

Template = """
  <ul class="centered background-message">
    <li class="message">
      <span class="title"></span>
      <a class="open-in-browser" href="#">Open in browser</a>
    </li>
  </ul>
"""

module.exports =
class BackgroundTitlesElement extends HTMLElement
  StartDelay: 250
  DisplayDuration: 4000
  FadeDuration: 500

  createdCallback: ->
    @index = -1

    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPane => @updateVisibility()
    @disposables.add atom.workspace.onDidDestroyPane => @updateVisibility()
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateVisibility()

    @startTimeout = setTimeout((=> @start()), @StartDelay)

  attachedCallback: ->
    @innerHTML = Template
    @message = @querySelector('.message')

  destroy: ->
    @stop()
    @disposables.dispose()
    @destroyed = true

  attach: ->
    paneView = atom.views.getView(atom.workspace.getActivePane())
    top = paneView.querySelector('.item-views')?.offsetTop ? 0
    @style.top = top + 'px'
    paneView.appendChild(this)

  detach: ->
    @remove()

  updateVisibility: ->
    if @shouldBeAttached()
      @start()
    else
      @stop()

  shouldBeAttached: ->
    atom.workspace.getPanes().length is 1 and not atom.workspace.getActivePaneItem()?

  start: ->
    return if not @shouldBeAttached() or @interval?
    @randomizeIndex()
    @attach()
    @showNextTip()
    @interval = setInterval((=> @showNextTip()), @DisplayDuration)

  stop: ->
    @remove()
    clearInterval(@interval) if @interval?
    clearTimeout(@startTimeout)
    clearTimeout(@nextTipTimeout)
    @interval = null

  randomizeIndex: ->
    len = Titles.size
    @index = Math.round(Math.random() * len) % len

  showNextTip: ->
    @index = ++@index % Titles.size
    @message.classList.remove('fade-in')
    @nextTipTimeout = setTimeout @showCurrentTitle.bind(this), @FadeDuration

  showCurrentTitle: ->
    @message.children[0].innerText = Titles.get(@index).title || 'Loading...'
    @message.children[1].setAttribute('href', Titles.get(@index).url) || '#'

    @message.classList.remove('fade-out')
    @message.classList.add('fade-in')

  getKeyBindingForCurrentPlatform: (bindings) ->
    return unless bindings?.length
    return binding for binding in bindings when binding.selector.indexOf(process.platform) isnt -1
    return bindings[0]

module.exports = document.registerElement 'background-titles', prototype: BackgroundTitlesElement.prototype
