defaultDelegate = (options) ->
  authDelegate = new fyre.conv.RemoteAuthDelegate()
  authDelegate.login        = (handlers) ->
    if options.login
      options.login(handlers)

  authDelegate.logout       = (handlers) ->
    if options.logout
      options.logout(handlers)
  authDelegate.viewProfile  = (handlers, author) ->
    if options.viewProfile
      if options.viewProfile(handlers, author)
        handlers.success()

  authDelegate.editProfile  = (handlers, author) ->
    if options.editProfile
      if options.editProfile(handlers, author)
        handlers.success()

loadScriptAsync = null
(->
  __loadedScripts = []
  fjs = null
  loadScriptAsync = (source, id, content, options) ->
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

livefyreInitialized = false
@initLivefyre = (options) ->
  if livefyreInitialized
    throw "Livefyre has already been initialized"
  livefyreInitialized = true
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
      opts =
        network: options.network
        authDelegate: options.delegate || defaultDelegate(options)

      fyre.conv.load opts, [options.config], ->
        token = $.cookie(options.cookie_name || "livefyre_utoken")
        if token
          try
            fyre.conv.login(token)
          catch error
            window.console.log "Error logging in:", e if window.console

    element = loadScriptAsync "http://#{options.root}/wjs/v3.0/javascripts/livefyre.js", null, null, {"data-lf-domain": options.network}