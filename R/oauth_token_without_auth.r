init_oauth2.0_clientcred <-
  function (endpoint,
            app,
            scope = NULL,
            user_params = NULL,
            type = NULL,
            use_oob = getOption("httr_oob_default"),
            is_interactive = interactive(),
            use_basic_auth = TRUE)
  {
    if (!use_oob && !httr:::is_installed("httpuv")) {
      message("httpuv not installed, defaulting to out-of-band authentication")
      use_oob <- TRUE
    }
    if (isTRUE(use_oob)) {
      stopifnot(interactive())
      redirect_uri <- "urn:ietf:wg:oauth:2.0:oob"
      state <- NULL
    }
    else {
      redirect_uri <- oauth_callback()
      state <- httr:::nonce()
    }
    scope_arg <- paste(scope, collapse = " ")
    # authorize_url <-
    #   modify_url(endpoint$authorize, query = compact(
    #     list(
    #       client_id = app$key,
    #       scope = scope_arg,
    #       redirect_uri = redirect_uri,
    #       response_type = "code",
    #       state = state
    #     )
    #   ))
    # if (isTRUE(use_oob)) {
    #   code <- oauth_exchanger(authorize_url)$code
    # }
    # else {
    #   code <- oauth_listener(authorize_url, is_interactive)$code
    # }
    # req_params <-
    #   list(
    #     client_id = app$key,
    #     redirect_uri = redirect_uri,
    #     grant_type = "authorization_code",
    #     code = code
    #   )
    # if (!is.null(user_params)) {
    #   req_params <- utils::modifyList(user_params, req_params)
    # }
    if (isTRUE(use_basic_auth)) {
      req <- POST(
        endpoint$access,
        encode = "form",
        # body = req_params,
        authenticate(app$key, app$secret, type = "basic")
      )
    }
    else {
      req_params$client_secret <- app$secret
      req <- POST(endpoint$access, encode = "form", body = req_params)
    }
    stop_for_status(req, task = "get an access token")
    content(req, type = type)
  }
