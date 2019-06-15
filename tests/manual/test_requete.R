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
# client credential grant : https://tools.ietf.org/html/rfc6749#section-4.4
# # DATARTE doesn't implement OAuth 2.0 standard
# # (http://tools.ietf.org/html/rfc6750#section-2) so we extend the Token2.0
# # ref class to implement a custom sign method.
#
# # mytoken <- oauth2.0_token(datarte, app, use_basic_auth = T, without_auth_req = T)
# mytoken <- oauth2.0_token_RTE(datarte, app, use_basic_auth = T, without_auth_req = T, cache = F)

# TEST REQUETE
#


# Authentification --------------------------------------------------------

devtools::dev_mode()
# need github httr branch
# remotes::install_github("hadley/httr#388")
devtools::load_all()

# configure env variable before
datarte_auth()

get_current_token(T)

is_token_available()

# Test --------------------------------------------------------------------

test1 <- RegistreAPI()

test2 <- unavailabilityAPI(ressource = "generation_unavailabilities")
