.onLoad <- function(libname, pkgname) {
  .state$client_id <- Sys.getenv("OPENDATARTE_CLIENT", unset = "")
  .state$client_secret <- Sys.getenv("OPENDATARTE_SECRET", unset = "")

  # URL for data RTE API
  .state$datarte_url <- getOption("opendatarte.base_url",
                                  default = "https://digital.iservices.rte-france.com/")

  invisible()
}
