function createConnection() {

    var config = {
        server  : "SERVER.database.windows.net",
        userName: "USER",
        password: "PASSWORD",
        // If you're on Azure, you will need this:
        options: { encrypt: true, database: 'DATABASE' }
    };
    
    var Connection = require('tedious').Connection;
    var connection = new Connection(config);
    
    return connection;
}

function createRequest(query, connection) {
    var Request = require('tedious').Request;
    var req =
        new Request(query, 
                function (err, rowCount) {
                    if (err) {
                        throw err;
                    }
                    connection && connection.close();
                });

    return req;
}

function stream (query, connection, output, defaultContent) {
    
    var request = query;
    if (typeof query == "string") {
        request = this.createRequest(query, connection);
    }
    pipe(request, output, defaultContent);
}

function pipe (request, output, defaultContent) {
    var empty = true;
    request.on('row', function (columns) {
        empty = false;
        output.write(columns[0].value);
    });

    request.on('done', function (rowCount, more, rows) {
        _OnDone(empty, defaultContent, output);
    });

    request.on('doneProc', function (rowCount, more, rows) {
        _OnDone(empty, defaultContent, output);
    }); 
}

function _OnDone(empty, defaultContent, output) { 
        if(empty) { 
            output.write(defaultContent);
        } 
        try { output.end(); } catch (err) { /* Ignore stream close error. */ }
    }

function executeRequest (request, connection) { 
        connection.on('connect', function (err) {
            if (err) {
                throw err;
            }
            connection.execSql(request);
        });
}

module.exports.createConnection = createConnection;
module.exports.createRequest = createRequest; 
module.exports.executeRequest = executeRequest;
module.exports.stream = stream;
module.exports.pipe = pipe;