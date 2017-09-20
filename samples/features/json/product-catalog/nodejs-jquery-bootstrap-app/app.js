var express = require('express');
var bodyParser = require('body-parser');

var app = express();
app.use(express.static('wwwroot'));
//app.use(bodyParser.json());
app.use(bodyParser.text({ type: 'application/json' }))
app.use('/api/Product', require('./routes/products'));

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    var err = new Error('Not Found' + req.originalUrl);
    err.status = 404;
    next(err);
});
app.set('port', process.env.PORT || 3000);

var server = app.listen(app.get('port'), function() {
    console.log('Express server listening on port ' + server.address().port);
});

module.exports = app;
