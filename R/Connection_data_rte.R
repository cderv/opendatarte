library(httr)

# 1. Find OAuth settings:
base_url <- "https://digital.iservices.rte-france.com/"
auth_url <- modify_url(base_url, path = "/token/oauth/")
datarte <- oauth_endpoint(NULL,authorize = "", access = "",
                          base_url = auth_url)

# 2. Register an application at https://www.linkedin.com/secure/developer
#    Make sure to register http://localhost:1410/ as an "OAuth 2.0 Redirect URL".
#    (the trailing slash is important!)
#
#    Replace key and secret below.
client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
app <- oauth_app("data.rte", client_id, client_secret)

# 3. Get OAuth credentials
# DATARTE doesn't implement OAuth 2.0 standard
# (http://tools.ietf.org/html/rfc6750#section-2) so we extend the Token2.0
# ref class to implement a custom sign method.
TokenDataRTE <- R6::R6Class("TokenDataRTE", inherit = httr:::Token2.0, list(
  init_credentials = function() {
    self$credentials <- init_oauth2.0_clientcred(self$endpoint, self$app,
                                      scope = self$params$scope, user_params = self$params$user_params,
                                      type = self$params$type, use_oob = self$params$use_oob,
                                      use_basic_auth = self$params$use_basic_auth)
  },
  can_refresh = function() {
    FALSE
  },
  refresh = function() {
    stop("Not implemented")
  }
))

token <- TokenDataRTE$new(
  endpoint = datarte,
  app = app,
  params = list(use_basic_auth = T)
)
oauth2.0_token_RTE <- function(endpoint, app, scope = NULL, user_params = NULL,
                           type = NULL, use_oob = getOption("httr_oob_default"),
                           as_header = TRUE,
                           use_basic_auth = TRUE,
                           cache = getOption("httr_oauth_cache")) {
  params <- list(scope = scope, user_params = user_params, type = type,
                 use_oob = use_oob, as_header = as_header,
                 use_basic_auth = use_basic_auth)

  TokenDataRTE$new(app = app, endpoint = endpoint, params = params,
               cache_path = cache)
}

token <- oauth2.0_token_RTE(datarte, app, use_basic_auth = T, )

# 4. Use API
url <- "https://digital.iservices.rte-france.com/open_api/consumption/v1/sandbox"
url <- "https://digital.iservices.rte-france.com/open_api/consumption/v1"
url <- "https://httpbin.org/get"
req <- GET(url, config(token = token))
req$content
stop_for_status(req)
content(req, 'text')
