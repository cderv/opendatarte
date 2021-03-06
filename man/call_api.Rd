% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_calls.r
\name{call_api}
\alias{call_api}
\title{Generic function to call RTE Data API}
\usage{
call_api(ressource_path, refresh = TRUE, verbose = FALSE)
}
\arguments{
\item{ressource_path}{string. Endpoint of the ressource as describe in data rte API documentation available on
data.rte-france.com (part of the url after /open_api/)}

\item{refresh}{logical. force to \code{FALSE} to prevent refresh}

\item{verbose}{logical.}
}
\value{
an \code{rte_api} object as a list with
\enumerate{
\item content: the parsed json resulting from the API call
\item path: the ressource called by the API request
\item response: the raw response from the API call.
}
}
\description{
This function is the base one used in each of the different API functions. It
is ressource generic and could be adapted to call the available ressource
on the data RTE portal.
}
