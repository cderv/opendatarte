# 1. Find OAuth settings & config app
base_url <- "https://digital.iservices.rte-france.com/"
auth_url <- modify_url(base_url, path = "/token/oauth/")
datarte <- oauth_endpoint(NULL,authorize = "", access = "",
                          base_url = auth_url)

client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
app <- oauth_app("data.rte", client_id, client_secret)

# 3. Get OAuth credentials
# DATARTE doesn't implement OAuth 2.0 standard
# (http://tools.ietf.org/html/rfc6750#section-2) so we extend the Token2.0
# ref class to implement a custom sign method.

# mytoken <- oauth2.0_token(datarte, app, use_basic_auth = T, without_auth_req = T)
mytoken <- oauth2.0_token_RTE(datarte, app, use_basic_auth = T, without_auth_req = T)

# TEST REQUETE

Registre_sandobox <- "https://digital.iservices.rte-france.com/open_api/certified_capacities_registry/v1/sandbox"

RegistreAPI <- function(path = "ncc_greater_equal_100_mw", mytoken){
  if(missing(mytoken)) {stop("La création d'un token est nécessaire pour l'API")}
  resp <- GET(file.path(Registre_sandobox, path), config(token = mytoken))
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  resp_json <-jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  structure(
    list(
      content = resp_json,
      path = path,
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

RegistreAPI(mytoken = mytoken)
