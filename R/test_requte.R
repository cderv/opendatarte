# # 1. Find OAuth settings & config app
# base_url <- "https://digital.iservices.rte-france.com/"
# auth_url <- modify_url(base_url, path = "/token/oauth/")
# datarte <- oauth_endpoint(NULL,authorize = "", access = "",
#                           base_url = auth_url)
#
# client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
# client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
# app <- oauth_app("data.rte", client_id, client_secret)
#
# # 3. Get OAuth credentials
# # DATARTE doesn't implement OAuth 2.0 standard
# # (http://tools.ietf.org/html/rfc6750#section-2) so we extend the Token2.0
# # ref class to implement a custom sign method.
#
# # mytoken <- oauth2.0_token(datarte, app, use_basic_auth = T, without_auth_req = T)
# mytoken <- oauth2.0_token_RTE(datarte, app, use_basic_auth = T, without_auth_req = T)

# TEST REQUETE

client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
datarte_auth(client_id = client_id, client_secret = client_secret, cache = F)


RegistreAPI <- function(ressource = NULL, sandbox = T, refresh = T){
  registre_path <- "certified_capacities_registry/v1"
  if (sandbox) registre_path <- file.path(registre_path, "sandbox")
  if (is.null(ressource)){
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
  req_path <- httr::modify_url(.state$datarte_url,
                               path = "open_api")
  resp <- httr::GET(file.path(req_path, ressource_path), datarte_token())
  if(resp$status_code == 403L & refresh){
    message("Auto-refreshing stale OAuth token.")
    mytoken <- resp$request$auth_token$refresh()
    return(RegistreAPI(ressource = ressource, sandbox = sandbox, refresh = FALSE))
  }
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  resp_json <-jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = FALSE)

  structure(
    list(
      content = resp_json,
      path = ressource_path,
      response = resp
    ),
    class = "rte_api"
  )
}

print.rte_api <- function(x, ...) {
  cat("<RTE ", x$path, ">\n", sep = "")
  str(x$content)
  invisible(x)
}

