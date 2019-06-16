
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opendatarte

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/opendatarte)](https://cran.r-project.org/package=opendatarte)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of opendatarte is to help connect to
<https://data.rte-france.com> and access data from its different
resources API.

**This package is in development.**

  - The authentication mechanism is rather stable. It won’t change a lot
    in the future.
  - The functions to call ressources may evolve to have cleaner R API
    and to be easy to maintain. It may change heavily in the future.

## Installation

The package is not on CRAN yet. You can installed the development
version from [GitHub](https://github.com/) with:

  - using `install-github.me` service

<!-- end list -->

``` r
source("https://install-github.me/cderv/opendatarte")
```

  - using `remotes`

<!-- end list -->

``` r
# install.packages("remotes")
remotes::install_github("cderv/opendatarte")
```

  - using `devtools`

<!-- end list -->

``` r
# install.packages("devtools")
devtools::install_github("cderv/opendatarte")
```

  - using `pak`

<!-- end list -->

``` r
pak::pkg_install("cderv/opendatarte")
```

## How to use

### Create an application and register some API

This package is useful to connect to your application on
<https://data.rte-france.com>. Connect to the website, create an account
and add an application. You can follow the help on the website.

Once your application is created you’ll get a *client\_id* and a
*secret\_id*. You will need them to connect to your application form R
using this package.

### Configure R client to authenticate

``` r
library(opendatarte)
```

The main fonction is `datarte_auth()`. The simplest way to use it is to
configure your R session with some environment variable containing your
secrets: `RTE_API_CLIENT` and `RTE_API_SECRET`.

To configure them you can use `usethis::edit_r_environ()`.

``` r
datarte_auth()
```

You can also provide *client\_id* and *secret\_id* as argument directly.

``` r
datarte_auth(client_id = "xxxxxxxxxx", client_secret = "xxxxxxxxxxxxxx")
```

or even, for advanced use, an httr token object directly in the token
argument

``` r
datarte_auth(token = "a-stored-token.rds")
```

All this will do the same: It will configure you current R session so
that the package opendatarte knows the credentials. You can then use the
API using this package without no further authentication step.

This package is also compatible with the cache mechanism from httr. You
can set `cache = TRUE` so that token is saved to disk and will be reused
in future sessions, and not just the current session.

If you want to use `httr` directly and not this package for accessing
the data, you can

  - save the object to reuse it in httr

<!-- end list -->

``` r
my_token <- datarte_auth()
auth_rte <- httr::config(token = my_token)
```

You can put it any calls from `httr` like this

``` r
httr::GET("https://httpbin.org/get", auth_rte)
```

The authentication will be handle to access the data

  - use the helper provided in this package. It will pass the token to
    the API correctly

<!-- end list -->

``` r
datarte_auth()
httr::GET("https://httpbin.org/get", datarte_token())
```

### Access data from the API using this package

There is some functions included in this package to be use with specific
ressources. They aim at easing the use of the API by wrapping endpoints
and query parameter.

They are all built on the same following concepts

  - In an interactive session, if several types of data are available
    for the same ressource, it will ask the one you want to use

<!-- end list -->

``` r
# get data from the 
res <- RegistreAPI()
```

  - You can provide a ressource path directly

<!-- end list -->

``` r
res <- RegistreAPI("ncc_less_100_mw")
```

  - By default, it will use the sandbox url (see api documentation for
    details). Use `sandbox = FALSE` if needed.

<!-- end list -->

``` r
res <- RegistreAPI("ncc_less_100_mw", sandbox = FALSE)
```

  - It will refresh your token automatically if it has expired. You can
    prevent that using `refresh = FALSE`

<!-- end list -->

``` r
res <- RegistreAPI("ncc_less_100_mw", refresh = FALSE)
```

The results are currently of the following structure. It is a list with
3 elements

  - `res$content`: The parsed json as a list
  - `res$path`: the ressource path from where are the data
  - `res$response`: The httr response object. Could be useful for
    advanced use.

### About available resources

All the ressources are not yet available in this package. The way to
expose all the ressource is not clear yet and this could evolved.

Available ressource are :

  - Unavailability Additional Information
  - Certified Capacities Registry

#### Advanced Usage: Getting more resources

All the function are built upon `call_api` that can be used with any
resource path for the api
documentation.

``` r
res <- call_api("unavailability_additional_information/v1/sandbox/transmission_network_unavailabilities")
```

Main advantage is that it will return the same type of objects are
previous functions and know how to use authentication.

You can also use `httr` directly by using the token `datarte_token()` in
the call to the API. You can also use any other request package, you can
get the current access token with `get_current_token(TRUE)` to be used
with any tool you prefere, according the API documentation

# In the future

  - Add a mechanism to add more resources and update them
  - Add mechanism to connect also to
    <https://opendata.reseaux-energies.fr>
  - Add functions to get result as tibble and not just list from parsed
    json.

# Other related package

There is also the [rte.data](https://github.com/dreamRs/rte.data) that
will work to use the data.rte-france.com API
