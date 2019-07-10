var express = require('express');
var os = require("os");
var app = express();
var hostname = os.hostname();
app.get('/', function (req, res) {
  res.send('Hello World! from host: '+hostname);
});
app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});