TokenDataRTE <- R6::R6Class("TokenDataRTE", inherit = httr:::Token2.0, list(
  can_refresh = function() {
    TRUE
  },
  refresh = function() {
    cred <- init_oauth2.0(
      endpoint = self$endpoint,
      app = self$app,
      user_params = self$params$user_params,
      use_basic_auth = self$params$use_basic_auth,
      without_auth_req = self$params$without_auth_req
    )
    if (is.null(cred)) {
      remove_cached_token(self)
    } else {
      self$credentials <- cred
      self$cache()
    }
    self
  }
)
)

oauth2.0_token_RTE <-function(endpoint,
                              app,
                              scope = NULL,
                              user_params = NULL,
                              type = NULL,
                              use_oob = getOption("httr_oob_default"),
                              as_header = TRUE,
                              use_basic_auth = TRUE,
                              without_auth_req = TRUE,
                              cache = getOption("httr_oauth_cache")) {
  params <-
    list(
      scope = scope,
      user_params = user_params,
      type = type,
      use_oob = use_oob,
      as_header = as_header,
      use_basic_auth = use_basic_auth,
      without_auth_req = without_auth_req
    )

  TokenDataRTE$new(
    app = app,
    endpoint = endpoint,
    params = params,
    cache_path = cache
  )
}
