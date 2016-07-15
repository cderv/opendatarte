library(httr)

# 1. Find OAuth settings:
base_url <- "https://digital.iservices.rte-france.com/"
auth_url <- modify_url(base_url, path = "/token/oauth/")
datarte <- oauth_endpoint(NULL,authorize = "", access = "",
                          base_url = auth_url)
client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
app <- oauth_app("data.rte", client_id, client_secret)

# 3. with httr @cderv branche perso
mytoken <- oauth2.0_token(datarte, app, use_basic_auth = F, without_auth_req = T)
