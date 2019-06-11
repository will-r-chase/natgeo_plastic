var url ='https://www.instagram.com/p/Bw2zIiYhFV7/';
var page = new WebPage();
var fs = require('fs');
var outpath ='9_html.html';

page.open(url, function (status) {
        just_wait();
});

function just_wait() {
    setTimeout(function() {
               fs.write(outpath, page.content, 'w');
            phantom.exit();
    }, 2500);
}

