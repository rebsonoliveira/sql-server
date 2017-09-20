var express = require('express');
var router = express.Router();

var db = require('../db.js');
var TYPES = require('tedious').TYPES;

/* GET products. */
router.get('/', function (req, res) {
    db.stream("select ProductID, Name, Color, Price, Quantity, JSON_VALUE(Data, '$.MadeIn') as MadeIn, JSON_QUERY(Tags) as Tags from Product FOR JSON PATH, ROOT('data')", db.createConnection(), res, '[]');
});

/* GET single product. */
router.get('/:id', function (req, res) {
    
    var conn = db.createConnection();

    var request = db.createRequest("select ProductID, Name, Color, Price, Quantity, JSON_VALUE(Data, '$.MadeIn') as MadeIn, JSON_QUERY(Tags) as Tags from Product where productid = @id for json path, without_array_wrapper", conn); 
    request.addParameter('id', TYPES.Int, req.params.id);
    db.stream(request, conn, res, '{}');
});

/* POST create product. */
router.post('/', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("EXEC InsertProductFromJson @json", connection);
    
    request.addParameter('json', TYPES.NVarChar, req.body);
    
    db.executeRequest(request, connection);

    res.end();
});

/* PUT update product. */
router.put('/:id', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("EXEC UpdateProductFromJson @id, @json", connection);
    request.addParameter('id', TYPES.Int, req.params.id);
    request.addParameter('json', TYPES.NVarChar, req.body);
    
    db.executeRequest(request, connection);

    res.end();
});

router.delete('/:id', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("DELETE Product WHERE ProductId = @id", connection);
    request.addParameter('id', TYPES.Int, req.params.id);
    
    db.executeRequest(request, connection);

    res.end();
});

module.exports = router;