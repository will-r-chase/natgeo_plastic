let counter = document.getElementById("counter");
const increment = 1010.44 / 10;
let bigFormat = d3.format(",.0f");
let amount = 0;

update = () => {
  counter.innerText = 'Since you visited this page there were ' + bigFormat(amount) + ' kilograms of plastic put into the ocean.';
};

update();

setInterval(function() {
  amount += increment;
  update();
}, 100);
