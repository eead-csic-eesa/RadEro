% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot}
\alias{plot}
\title{Plot of experimental and simulated profile inventories}
\usage{
plot(data1, data2, dir1, dir2, AxisMaxValue, cell_value)
}
\arguments{
\item{data1}{Character. Read input data in CSV format.}

\item{data2}{Filtered values of data1 for the current 'id'.}

\item{dir1}{directory. Temporary working directory where the '_num.txt' and '_exp.txt' files were created.}

\item{dir2}{directory. Current working directory.}

\item{AxisMaxValue}{daximum value to determine the x axis limit. Only used if the user wants to escalate all the simulated profiles .}

\item{cell_value}{Unit cell size in meters.}
}
\value{
Results folder in dir2 with n plots saved as a PNG based on the n "id" defined in data2. Results summarized TXT file in the results folder.
}
\description{
'plot' returns two plots corresponding to the experimental and simulated inventories for each profile defined in the input data. Automatic function when you execute RadEro_run. It creates results folder in the current directory if didn't exist.
}
