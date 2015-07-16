LoadingTitle =
  title: 'Fetching data from HackerNews'

# Items = new Set
HackerNewsTitles = new Map
HackerNewsTitles.set(0, LoadingTitle)

getItem = (itemId) ->
  request = new XMLHttpRequest()
  request.open 'GET', 'https://hacker-news.firebaseio.com/v0/item/' + itemId + '.json', true

  request.onload = (e) ->
    if (request.readyState == 4 && request.status == 200)
      HackerNewsTitles.set HackerNewsTitles.size, JSON.parse(request.responseText)

  request.send null

getTopStores = () ->
  request = new XMLHttpRequest()
  request.open 'GET', 'https://hacker-news.firebaseio.com/v0/topstories.json', true

  request.onload = (e) ->
    if (request.readyState == 4 && request.status == 200)
      items = JSON.parse(request.responseText)[0..6]

      for itemId in items
        getItem(itemId)

  request.ontimeout = (e) ->
    getTopStores()

  request.onerror = (e) ->
    getTopStores()

  request.send null


# Get HackerNews titles
getTopStoresRetry = () ->
  # Try
  getTopStores()

  setTimeout () ->
    # Retry
    getTopStoresRetry() unless (HackerNewsTitles.size > 2)
  , 2000
getTopStoresRetry()

module.exports = HackerNewsTitles
