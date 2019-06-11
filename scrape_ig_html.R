library(tidyverse)
library(rvest)
library(jsonlite)
# write the javascript code to a new file, scrape.js

writeLines("var url = 'http://therapboard.com';
var page = new WebPage();
var fs = require('fs');
var outpath = 'link.html';

page.open(url, function (status) {
        just_wait();
});

function just_wait() {
    setTimeout(function() {
               fs.write(outpath, page.content, 'w');
            phantom.exit();
    }, 2500);
}
", con = "scrape.js")

js_scrape <- function(url = "https://www.instagram.com/p/BwmfxXuly2J/", 
                      js_path = "scrape.js", 
                      phantompath = "/usr/local/bin/phantomjs",
                      outpath = "1_html.html"){
  
  # this section will replace the url in scrape.js to whatever you want 
  lines <- readLines(js_path)
  lines[1] <- paste0("var url ='", url ,"';")
  lines[4] <- paste0("var outpath ='", outpath, "';")
  writeLines(lines, js_path)
  
  command = paste(phantompath, js_path, sep = " ")
  system(command)
  
}

extract_json <- function(input) {
  input %>% 
    html_nodes(xpath = '//script[@type="application/ld+json"]') %>%
    html_text() %>%
    str_remove(., "\\n                ") %>%
    str_remove(., "\\n            ") %>%
    fromJSON()
}

urls <- fromJSON("output_1000_05052019.json")

for(i in 1:nrow(urls)) {
  print(i)
  js_scrape(url = urls$key[i], outpath = paste0(i, "_html.html"))
}

htmls <- as.list(fs::dir_ls(regexp = "_html.html")) %>%
  map( ~read_html(.x)) %>%
  map( ~tryCatch(extract_json(.x), error = function(e) NA))

names(htmls) <- str_pad(names(htmls), 14, side = "left", pad = "0")
htmls_sort <- htmls[order(names(htmls))]

htmls_content <-
  htmls_sort %>%
  #map( ~tryCatch(purrr::flatten(.x), error = function(e) NA)) %>%
  map( ~tryCatch(chuck(.x, "caption"), error = function(e) NA))

json_export <- toJSON(htmls_sort, dataframe = "columns", pretty = TRUE)
write(json_export, "ig_posts_json.json")
