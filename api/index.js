// import system dependencies to run local commands
var exec        = require('child_process').exec;

// import rest server module
var restify     = require('restify');

// generate the server and configure it
var server = restify.createServer({
    name: 'ARK Server Tools API',
    version: '1.4.0'
});
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());

// use this function to run a command to the host server and retrieve the stdout and stderr
function execute(command, callback){
    exec(command, function(error, stdout, stderr){ callback(stdout, stderr); });
}

// ========================================================== //
// define here the functions used to interact with the server //
// ========================================================== //

function status() {
    execute('arkmanager status', function(stdout, stderr) {
        console.log('stdout:', stdout);
        console.log('stderr:', stderr);
        return stdout;
    });
}

// ============================================ //
// define here the routes                       //
// doc at https://www.npmjs.com/package/restify //
// ============================================ //

server.get('/status', function(req, res, next) {
    // return the output of `status` and JSONify it
    res.send(JSON.parse(status()));
    // move to the next route
    return next();
});


// start the REST server
// it will listen on port 3100
server.listen(3100, function () {
    console.log('%s listening at %s', server.name, server.url);
});
