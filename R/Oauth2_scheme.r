#' Produces token for data.rte-france.com
#'
#' If token is not already available in the current session, this function will stop execution.
#' An active token for the current session must be requested before any other task.
#'
#' Use [get_current_token()] to check for valid token.
#'
#' @return a `request` object (an S3 class provided by `httr`). It is the token prepared for
#' use with httr configuration system. see [httr::config()].
#'
#' @export
#' @keywords internal
#' @examples
#'   \dontrun{
#'   # use in httr fonction like GET for authentification as config for httr
#'   datarte_auth(client_id, client_secret)
#'   httr::GET("https://httpbin.org/get", datarte_token())
#'   }
datarte_token <- function(verbose = FALSE) {
  if (!is_token_available(verbose = verbose)) {
    stop("No token available in current session.\n",
         "Use function datarte_auth() to explicitly authentificate with client id and client secret \n",
         "and get a valid token. See ?datarte_auth.", call. = F)
  }
  httr::config(token = .state$token)
}

# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Check for token existence
#'
#' This function checks if a token exist in the internal
#' `.state` environment of the package
#'
#' @return logical
#' @keywords internal
#' @export
is_token_available <- function(verbose = TRUE) {
  if (is.null(.state$token)) {
    if (verbose) {
      if (file.exists(".httr-oauth")) {
        message(".httr-oauth file exists in current working directory.\n",
                "the credentials cached in .httr-oauth by httr package mechanism.",
                "It will be used for this session.\n",
                "Use explicit authentification or suppress the file ",
                "if you want otherwise")
      } else {
        message("No .httr-oauth file exists in current working directory.\n",
                "by default one will be created at first authentification\n",
                "Use explicit authentification with cache = F to override this")
      }
    }
    return(FALSE)
  }
  TRUE
}

#' Get current active token
#'
#' @param only_access_token logical. Default to `FALSE`
#'
#' @return If `TRUE`, just the token string is returned not the whole token object.
#' If no token is available, for the current session, it returns `NULL`
#'
#' @export
#'
#' @examples
#' get_current_token() # Returns NULL or token object credentials
#' get_current_token(TRUE) # Returns NULL or access token string only.
get_current_token <- function(only_access_token = F){
  if (!is_token_available(verbose = TRUE)) {
    message("No token available. Get a valid token for current session with datarte_auth function.")
    return(NULL)
  }
  if (only_access_token) {
    return(.state$token$credentials$access_token)
  }
  .state$token$credentials
}

#' Obtain credentials for RTE Data API
#'
#' It is the main fonction to use for accessing RTE Data API. It will request an access token for
#' the current session if none currently exists and be valid.
#'
#' You can configure your R session to use always some client and secret by
#' setting `RTE_API_CLIENT` and `RTE_API_SECRET` environment variable
#' with `base::Sys.setenv()`
#'
#' @references This function is inspired by `googlesheet` package and its Oauth2 system.
#'
#' @param token optional argument. it exists to supply manually a token.
#' \itemize{
#'    \item if `NULL` (the default), the current token for the active session will be used.
#'    \item if a `character`, it assumes to be the path to a *rds*
#'    file containing a valid Token2.0 object from httr
#'    \item a `Token2.0` object directly
#' }
#' @param client_id character. the client id for the app. default `NULL` - will
#'   use the `RTE_API_CLIENT` environment variable.
#' @param client_secret character. the client secret for the app. default `NULL`
#'   - will use the `RTE_API_SECRET` environment variable.
#' @param cache logical or a string. `TRUE` to cache the access token into a
#'   file. A string means use the specified file. See `httr::oauth2.0_token()`
#'   for details.
#'
#' @return invisibly the `Token` which is saved for the current session,
#'   and will be used when needed.
#' @export
#'
#' @examples
#' \dontrun{
#' client_id <- "cliend_id"
#' client_secret <- "client_secret"
#' datarte_auth(client_id = client_id, client_secret = client_secret, cache = F)
#' }
datarte_auth <- function(token = NULL,
                         client_id = NULL,
                         client_secret = NULL,
                         cache = FALSE){
  if (is.null(token)) {
    if (!is_token_available(verbose = F)) {
      if (is.null(client_id)) client_id <- .state$client_id
      if (!nzchar(client_id)) stop("No client_id configured. Provide one or set `RTE_API_CLIENT`")
      if (is.null(client_secret)) client_secret <- .state$client_secret
      if (!nzchar(client_secret)) stop("No client_id configured. Provide one or set `RTE_API_SECRET`")
      datarte_endpoints <- httr::oauth_endpoint(authorize = NULL,
                                                access = "token/oauth/",
                                                base_url = .state$datarte_url)

      datarte_app <- httr::oauth_app("datarte", client_id, client_secret)

      datarte_token <- httr::oauth2.0_token(endpoint = datarte_endpoints,
                                            app = datarte_app,
                                            use_basic_auth = TRUE,
                                            client_credentials = TRUE,
                                            cache = cache)
      .state$token <- datarte_token
    }
  } else if (inherits(token, "Token2.0")) {
    .state$token <- token
  } else if (inherits(token, "character")) {
    datarte_token <- purrr::possibly(readRDS, otherwise = NULL, quiet = T)(token)
    if (is.null(datarte_token)) {
      stop(sprintf("Cannot read token from alleged .rds file:\n%s", token), call. = F)
    } else if (!is_token(datarte_token, verbose = TRUE)) {
      stop(sprintf("File does not contain a proper token:\n%s", token), call. = F)
    }
    .state$token <- datarte_token
  } else {
    stop("Input provided via 'token' is neither a",
         "token,\nnor a path to an .rds file containing a token.", call. = F)
  }
  invisible(.state$token)
}

#' Check that object is indeed a token
#'
#' @param x a R object to test
#' @param verbose `TRUE` for printing message
#'
#' @return logical. `TRUE` is if the object is a valid [TokenDataRTE()]
#' object for use with this package. `FALSE` otherwise.
#'
#' @export
#' @keywords internal
is_token <- function(x, verbose = FALSE) {
  if (!inherits(x, "Token2.0")) {
    if (verbose) message("Not a Token2.0 object from httr")
    return(FALSE)
  }
  TRUE
}
