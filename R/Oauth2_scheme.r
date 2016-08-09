#' OAuth token objects for RTE Data API
#'
#' This objects is a specific Oauth Token Object derived from the ones in \code{httr}
#' package for Oauth authentification. It inherits from \code{\link[httr]{Token2.0}} objects by modifying
#' its refresh methods. Use \code{\link{oauth2.0_token_RTE}} to create the object.
#'
#' @section Warnings:
#' Official \code{httr} packages is not compatible with Oauth2 client credential grant. It is why
#' the version of httr needed is on Github cderv/httr@client_credential_grant, until PR is merged.
#'
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @importFrom R6 R6Class
#' @export
TokenDataRTE <- R6::R6Class("TokenDataRTE", inherit = httr:::Token2.0, list(
  can_refresh = function() {
    TRUE
  },
  refresh = function() {
    cred <- httr::init_oauth2.0(
      endpoint = self$endpoint,
      app = self$app,
      user_params = self$params$user_params,
      use_basic_auth = self$params$use_basic_auth,
      without_auth_req = self$params$without_auth_req
    )
    if (is.null(cred)) {
      httr:::remove_cached_token(self)
    } else {
      self$credentials <- cred
      self$cache()
      .state$token$credentials <- cred
    }
    self
  }
)
)

#' Create a *TokenDataRTE* object
#'
#' This is the main object for Oauth2 authentification to connect to RTE Data
#' API. It contains everything needed for the connection.This function should
#' not be called directly. \code{\link{datarte_auth}} should be use instead and
#' calls this function.
#'
#' This fonction is derived from \code{\link[httr]{oauth2.0_token}}
#'
#' @inheritParams httr::oauth2.0_token
#'
#' @return A \code{TokenDataRTE} object for use in \code{\link{datarte_auth}}
#' @export
oauth2.0_token_RTE <- function(endpoint,
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

#' Produce token for data.rte-france.com
#'
#' If token is not already available in the current session, this function will stop execution.
#' A token for the current session must be requested before any other task.
#'
#' Use \code{\link{get_current_token}} to check for valid token.
#'
#' @return a \code{request} object (an S3 class provided by \code{httr}). It is the token prepared for
#' use with httr configuration system. see \code{\link[httr]{config}}.
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
         "Use datarte_auth to explicitly authentificate with client id and client secret \n",
         "and get a valid token.", call. = F)
    # datarte_auth(verbose = verbose)
  }
  httr::config(token = .state$token)
}

# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Check for token existence
#'
#' This function checks if a token exist in the internal
#' \code{.state} environment of the package
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
#'
#'
#' @param only_access_token logical. Default to \code{FALSE}
#'
#' @return If \code{TRUE}, just the access_token is returned not the whole token.
#' If no token is available, for the current session, it return \code{NULL}
#' @export
#'
#' @examples
#' get_current_token() # Return NULL or token credentials
#' get_current_token(T) # Return NULL or access token only.
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


# ID for christophe Dervieux acces on data RTE API application
.state$client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
.state$client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"

# URL for data RTE API
.state$datarte_url <- "https://digital.iservices.rte-france.com/"


#' Obtain credentials for RTE Data API
#'
#' It is the main fonction to use for accessing RTE Data API. It will request an access token for
#' the current session if none currently exists and be valid.
#'
#' This function is inspired by \code{googlesheet} package and its Oauth2 system.
#'
#' @param token optional argument. it exists to supply manually a token.
#' \itemize{
#'    \item if a \code{character}, it assumes to be the path to a \emph{rds}
#'    file containing a valid TokenDataRTE object
#'    \item an \code{TokenDataRTE} object
#'    \item if `NULL` (the default), the current token for the active session will be used. If
#' }
#' @param client_id character. the client id for the app
#' @param client_secret character. the client secret for the app
#' @param cache logical. \code{TRUE} to cache the access token in a file/
#'
#' @return invlisibly the \code{TokenDataRTE} which is save for the current session, and use when needed.
#' @export
#'
#' @examples
#' \dontrun{
#' client_id <- "cliend_id"
#' client_secret <- "client_secret"
#' datarte_auth(client_id = client_id, client_secret = client_secret, cache = F)
#' }
datarte_auth <- function(token = NULL,
                         client_id,
                         client_secret,
                         cache = F){
  if (is.null(token)) {
    if (!is_token_available(verbose = F)) {
      base_url <- .state$datarte_url
      auth_url <- httr::modify_url(base_url, path = "/token/oauth/")
      datarte_endpoints <- httr::oauth_endpoint(NULL,authorize = "", access = "",
                                                base_url = auth_url)

      datarte_app <- httr::oauth_app("datarte", client_id, client_secret)

      datarte_token <- oauth2.0_token_RTE(datarte_endpoints, datarte_app,
                                          use_basic_auth = T, without_auth_req = T, cache = cache)
      stopifnot(is_token_datarte(datarte_token, verbose = TRUE))
      .state$token <- datarte_token
    }
  } else if (inherits(token, "TokenDataRTE")) {
    stopifnot(is_token_datarte(token, verbose = TRUE))
    .state$token <- token
  } else if (inherits(token, "character")) {
    datarte_token <- purrr::possibly(readRDS, otherwise = NULL, quiet = T)(token)
    if (is.null(datarte_token)) {
      stop(sprintf("Cannot read token from alleged .rds file:\n%s", token), call. = F)
    } else if (!is_token_datarte(datarte_token, verbose = TRUE)) {
      stop(sprintf("File does not contain a proper token:\n%s", token), call. = F)
    }
    .state$token <- datarte_token
  } else {
    stop("Input provided via 'token' is neither a",
         "token,\nnor a path to an .rds file containing a token.", call. = F)
  }
  invisible(.state$token)
}

#' Check that object is a datarte token
#'
#' @param x a R object to test
#' @param verbose \code{TRUE} for printing message
#'
#' @return logical. \code{TRUE} is if the object is a valid \code{\link{TokenDataRTE}}
#' object for use with this package. \code{FALSE} otherwise.
#'
#' @export
#' @keywords internal
is_token_datarte <- function(x, verbose = FALSE) {
  if (!inherits(x, "TokenDataRTE")) {
    if (!inherits(x, "Token2.0")) {
      if (verbose) message("Not a TokenDataRTE object nor a Token2.0 object.")
      return(FALSE)
    } else {
      if (verbose) message("Not a TokenDataRTE object but a Token2.0 object.\n",
                           "Insure to create the token witth this packages")
      return(FALSE)
    }
  }
  TRUE
}

