const http = require('http')
const createHandler = require('WEBHOOK-HANDLER')
const handler = createHandler({
    path: '/webhook',
    secret: 'WEBHOOK_SECRET'
})

http.createServer((req, res) => {
    handler(req, res, err => {
        res.statusCode = 404
        res.end('webhook is running~~')
    })
}).listen(5000)

handler.on('error', err => {
    console.error('Error:', err.message)
})

// const process = require('child_process')
// handler.on('push', event => {
//     try {
//         process.execSync('git pull')
//     } catch (e) {
//         process.execSync('git checkout -- "*"')
//         process.execSync('git pull')
//     }
//     process.execSync('npm i')
//     process.execSync('npm stop')
//     process.execSync('npm start')
// })

handler.on('issues', event => {
    console.log('Received an issue event for %s action=%s: #%d %s',
        event.payload.repository.name,
        event.payload.action,
        event.payload.issue.number,
        event.payload.issue.title)
})

handler.on('push', function (event) {
    console.log('Received a push event for %s to %s',
        event.payload.repository.name,
        event.payload.ref);
    run_cmd('sh', ['./deploy.sh'], function (text) {
        console.log(text)
    });
})

function run_cmd(cmd, args, callback) {
    var spawn = require('child_process').spawn;
    var child = spawn(cmd, args);
    var resp = "";
    child.stdout.on('data', function (buffer) {
        resp += buffer.toString();
    });
    child.stdout.on('end', function () {
        callback(resp)
    });
}