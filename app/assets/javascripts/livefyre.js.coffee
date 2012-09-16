defaultDelegate = (options) ->
  authDelegate = new fyre.conv.RemoteAuthDelegate()
  authDelegate[k] = v for k, v of options.auth
  authDelegate

load = null
(->
  __loadedScripts = []
  fjs = null
  load = (source, id, content, options) ->
    content = null if !content
    return if (document.getElementById(id))
    return if __loadedScripts[id]
    __loadedScripts[id] = true
    fjs = document.getElementsByTagName('script')[0] unless fjs
    js = document.createElement("script")
    js.id = id
    js.async = true
    js.src = source
    js.innerHTML = content
    js[k] = v for k, v of options if options

    fjs.parentNode.insertBefore(js, fjs)
    js
)()

cookie = (token) ->
  m = document.cookie.match(new RegExp(token + "=([^;]+)"))
  if m then m[1] else null

utils = (options) ->
  obj =
    load: load
    startLogin: (url, width = 600, height = 400, callback = null) ->
      left = (screen.width / 2) - (width / 2)
      top = (screen.height / 2) - (height / 2)
      popup = window.open url, name, "menubar=no,toolbar=no,status=no,width=#{width},height=#{height},toolbar=no,left=#{left},top=#{top}"
      @finishCallback = callback
      @startLoginPopup(popup)

    startLoginPopup: (popup) ->
      @tries = 0
      @popup = popup
      @timer = setInterval(=>
        @tries += 1
        @__checkLogin()
      , 100)

    __checkLogin: ->
      token = cookie(options.cookie_name || "livefyre_utoken")
      if @popup
        try
          if @popup.closed == false and @tries > 30 # 3 seconds
             clearInterval(@timer)
             @timer = null
             @popup = null
        catch err

      if token
        clearInterval(@timer)
        @popup.close()
        @popup = null
        @timer = null
        @finishCallback() if @finishCallback
        window.fyre.conv.login(token)

_initialized = false
@initLivefyre = (options) ->
  if _initialized
    throw "Livefyre has already been initialized"
  _initialized = true
  e = document.getElementById(options.element_id || "livefyre_comments")
  if e
    options.config ||=
      checksum: e.getAttribute("data-checksum")
      collectionMeta: e.getAttribute("data-collection-meta")
      articleId: e.getAttribute("data-article-id")
      siteId: e.getAttribute("data-site-id")
      el: e.id

    options.network ||= e.getAttribute("data-network")
    options.domain  ||= e.getAttribute("data-domain")
    options.root    ||= e.getAttribute("data-root")

    @FYRE_LOADED_CB = ->
      options.preLoad(fyre) if options.preLoad
      opts =
        network: options.network
        authDelegate: options.delegate || defaultDelegate(options)

      fyre.conv.load opts, [options.config], ->
        token = cookie(options.cookie_name || "livefyre_utoken")
        if token
          try
            fyre.conv.login(token)
          catch error
            window.console.log "Error logging in:", e if window.console

    unless options.manualLoad
      element = load "http://#{options.root}/wjs/v3.0/javascripts/livefyre.js", null, null, {"data-lf-domain": options.network}
    utils(options)

  else
    null