#' Retrieve data from the capacity market public registry
#'
#' @param ressource name of the ressource to call in the API. Choices are
#'   describe in API documentation on the website
#'   <http://www.data.rte-france.com>
#' @param sandbox logical. `TRUE` to call the sandbox URL for testing
#' @param refresh lofical. `TRUE` to allow refresh.
#'
#' @family API-calls
#'
#' @export
RegistreAPI <- function(ressource = NULL, sandbox = T, refresh = T){
  registre_path <- "certified_capacities_registry/v1"
  if (sandbox) registre_path <- file.path(registre_path, "sandbox")
  if (is.null(ressource)) {
    if (!interactive()) {
      stop("ressource is missing", call. = F)
    } else {
      cat("which ressource do you want to access in the API \"", dirname(registre_path),"\"?", sep = "")
      choices <- c(
        "ncc_greater_equal_100_mw",
        "ncc_less_100_mw"
      )
      nb <- utils::menu(choices)
      if (nb == 0) stop("No ressource selected.", call. = F)
      ressource <- choices[nb]
    }
  }
  ressource_path <- file.path(registre_path, ressource)

  call_api(ressource_path = ressource_path, refresh = refresh)

}
