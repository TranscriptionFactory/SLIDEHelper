% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CorrelationFilter.R
\name{CorrelationFilter}
\alias{CorrelationFilter}
\title{Filter highly correlated variables out of input data. Examines number of correlations above correlation_threshold
that each feature has and then filters by correlation_percentile_filter across all features.}
\usage{
CorrelationFilter(
  data,
  correlation_threshold = 0.8,
  correlation_percentile_filter = 0.9,
  use_hist_to_filter_percentile = F
)
}
\arguments{
\item{data}{the data matrix}

\item{correlation_threshold}{double for correlation absolute value; correlations above this value will be examined for filtering.
Should be 0 < correlation_threshold < 1}

\item{correlation_percentile_filter}{double for percentile used to filter correlated features; Should be 0 < correlation_threshold < 1.
For each feature, number of other features this feature is correlated with (correlation >= correlation_threshold,
by absolute value) is counted. This filters based on percentile for this count across all features.}

\item{use_hist_to_filter_percentile}{logical to determine whether to bin correlation counts using a histogram and filter using the
percentile of the histogram breaks, rather than the percentile of the counts directly. Using this option can help smooth the distribution
of counts for finer grained filtering, but usually isn't necessary.}
}
\description{
Filter highly correlated variables out of input data. Examines number of correlations above correlation_threshold
that each feature has and then filters by correlation_percentile_filter across all features.
}
