#' Generic function to call RTE Data API
#'
#' This function is the base one used in each of the different API functions. It
#' is ressource generic and could be adapted to call the available ressource
#' on the data RTE portal.
#'
#' @param ressource_path string. adresse of the ressource as describe in data rte API documentation available on
#' data.rte-france.com (part of the addresse after /open_api/)
#' @param refresh logical. force to \code{FALSE} to prevent refresh
#'
#' @return an \code{rte_api} object as a list with
#'  \enumerate{
#'      \item content: the parsed json resulting from the API call
#'      \item path: the ressource called by the API request
#'      \item response: the raw response from the API call.
#'  }
#'
#' @export
#' @keywords internal
#'
#' @examples
call_api <- function(ressource_path, refresh = TRUE){
  assertthat::assert_that(assertthat::is.string(ressource_path))
  req_path <- httr::modify_url(.state$datarte_url,
                               path = "open_api")
  resp <- httr::GET(file.path(req_path, ressource_path), datarte_token())
  if (resp$status_code == 403L & refresh) {
    message("Auto-refreshing stale OAuth token.")
    .state$token <- resp$request$auth_token$refresh()
    return(call_api(ressource_path, refresh = FALSE))
  }
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  resp_text <- httr::content(resp, "text")
  if (is.na(resp_text)) {
    message("Nothing to return")
    resp_json <- list()
  } else {
    resp_json <- jsonlite::fromJSON(resp_text, simplifyVector = FALSE)
  }
  structure(
    list(
      content = resp_json,
      path = ressource_path,
      response = resp
    ),
    class = "rte_api"
  )
}

# Print method for rte_api class
print.rte_api <- function(x, ...) {
  cat("<RTE ", x$path, ">\n", sep = "")
  str(x$content)
  invisible(x)
}
