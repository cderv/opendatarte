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
#


# Authentification --------------------------------------------------------

devtools::dev_mode()
library("httr")
# client_id <- "8d48ab4d-bff2-47dd-b2a9-ee0add477830"
# client_secret <- "1d208734-4ec0-4bfc-9f1f-386f2ef4a822"
# source('R/oauth_token_without_auth.r')
datarte_auth(client_id = .state$client_id, client_secret = .state$client_secret, cache = F)


# Test --------------------------------------------------------------------

RegistreAPI()

unavailabilityAPI(ressource = "generation_unavailabilities")
