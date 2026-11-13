#!/usr/bin/env Rscript
# reducer.R - Consolidates locations per document

con <- file("stdin", open = "r")
on.exit(close(con), add = TRUE)

prev_file <- NULL
locations <- character(0)

flush_output <- function(f, locs) {
  if (!is.null(f) && length(locs) > 0) {
    cat(sprintf("%s\t%s\n", f, paste(locs, collapse = ",")))
  }
}

repeat {
  line <- readLines(con, n = 1L, warn = FALSE)
  if (length(line) == 0L) break

  parts <- strsplit(line, "\t", fixed = TRUE)[[1]]
  if (length(parts) < 2) next

  current_file <- parts[1]
  location     <- parts[2]

  if (is.null(prev_file)) {
    prev_file <- current_file
    locations <- location
  } else if (current_file == prev_file) {
    locations <- c(locations, location)
  } else {
    flush_output(prev_file, locations)
    prev_file <- current_file
    locations <- location
  }
}
flush_output(prev_file, locations)