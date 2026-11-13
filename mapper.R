#!/usr/bin/env Rscript
# mapper.R - Emits (filename, row:column) for each keyword occurrence

keyword <- Sys.getenv("SEARCH_KEYWORD", unset = "")
if (nchar(keyword) == 0) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) >= 1) {
    keyword <- args[1]
  } else {
    stop("SEARCH_KEYWORD not set and no keyword argument supplied.")
  }
}
keyword_lower <- tolower(keyword)

filename <- Sys.getenv("mapreduce_map_input_file", unset = "")
if (nchar(filename) == 0) filename <- Sys.getenv("map_input_file", unset = "")
if (nchar(filename) == 0) filename <- "stdin_input"
filename <- basename(filename)

con <- file("stdin", open = "r")
on.exit(close(con), add = TRUE)

row_num <- 0L

repeat {
  line <- readLines(con, n = 1L, warn = FALSE)
  if (length(line) == 0L) break
  row_num <- row_num + 1L

  line_lower <- tolower(line)
  matches <- gregexpr(keyword_lower, line_lower, fixed = TRUE)[[1]]

  if (matches[1] != -1L) {
    for (col in matches) {
      cat(sprintf("%s\t%d:%d\n", filename, row_num, col))
    }
  }
}