const width = 800;
const height = 400;

let line = d3
  .line()
  .x(d => d[0])
  .y(d => d[1])
  .curve(d3.curveBasisClosed);

let projection = d3
  .geoEqualEarth()
  .fitExtent([[0, 0], [width, height]], { type: "Sphere" })
  .precision(0.1);

let path = d3.geoPath().projection(projection);

let color = d3
  .scaleQuantile()
  .domain([0, 0.05])
  .range(d3.schemeBlues[9])
  .unknown("#ccc");

function round(x) {
  let my_path = path(x).split("M");
  my_path.shift();

  let land_rounded = [];
  my_path.forEach(d => {
    land_rounded.push(
      d
        .replace(/Z/, "")
        .split("L")
        .map(p => p.split(","))
    );
  });

  let curves = [];
  let curve_path = land_rounded.forEach(d => {
    curves.push(line(d));
  });

  return curves;
}

let tooltip = d3
  .select("body")
  .append("div")
  .attr("class", "tooltip")
  .style("opacity", 0)
  .style("position", "absolute");

d3.json("plastic_map.topojson").then(function(data) {
  const ms_countries = topojson.feature(data, data.objects.foo);
  console.log(ms_countries.features);

  const svg = d3.select("svg");

  const g = svg.append("g");

  g.selectAll(".land")
    .data(ms_countries.features)
    .join("path")
    .attr("fill", d => color(d.properties.plastic))
    .attr("d", round)
    .attr("class", "land")
    .attr("stroke", "black")
    .attr("stroke-opacity", 0)
    .on("mouseover", function(d) {
      tooltip
        .transition()
        .duration(250)
        .style("opacity", 1);
      tooltip
        .html(
          `
        Country: ${d.properties.ADMIN} </br>
        Mismanaged plastic (kg/person/day): ${d.properties.plastic}
        `
        )
        .style("left", d3.event.pageX + 28 + "px")
        .style("top", d3.event.pageY - 28 + "px");
    })
    .on("mouseout", function(d) {
      tooltip
        .transition()
        .duration(250)
        .style("opacity", 0);
    });

  g.append("path")
    .datum(topojson.mesh(data, data.objects.foo, (a, b) => a !== b))
    .attr("fill", "none")
    .attr("stroke", "white")
    .attr("stroke-linejoin", "round")
    .attr("d", path)
    .attr("stroke-opacity", 1);
});
