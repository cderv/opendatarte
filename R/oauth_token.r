
sandbox_api <- function(path) {
  url <- modify_url("https://digital.iservices.rte-france.com", path = path)
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  resp
}

resp <- sandbox_api("/open_api/consumption/v1/sandbox/short_term")

http_type(resp)




"https://digital.iservices.rte-france.com/open_api/consumption/v1/sandbox"
"https://digital.iservices.rte-france.com/open_api/consumption/v1"

# environment to store credentials
.state <- new.env(parent = emptyenv())


client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"

## auth_url <- NULL
base_url <- "https://digital.iservices.rte-france.com/"
auth_url <- modify_url(base_url, path = "/token/oauth/")

datarte <- oauth_endpoint(NULL,authorize = "", access = "",
                         base_url = auth_url)
app <- oauth_app("data.rte", client_id, client_secret)
# token <- oauth2.0_token(endpoint = datarte,app = app)


resp <- POST(datarte$access, encode = "form", authenticate(app$key, app$secret, type = "basic"))
ltoken <- content(resp)$access_token
