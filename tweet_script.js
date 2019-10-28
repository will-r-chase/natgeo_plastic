const ids = [{
  id: "1116429253095100416"
}, {
  id: "1115893041401925634"
}];

let tweets = d3.select(".tweets-wrapper")
  .selectAll(".tweet")
  .data(ids)
  .join("div")
  .attr("class", "tweet")
  .each(function(d, i) {
    twttr.widgets.createTweet(
        d.id, this, {
          conversation: 'all', // or all
          cards: 'visible', // or visible
          linkColor: '#cc0000', // default is blue
          theme: 'light' // or dark
    });
    console.log("iteration: " + i);
  });
