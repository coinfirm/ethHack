var app = require('http').createServer(handler)
var io = require('socket.io')(app);
var fs = require('fs');

app.listen(8080);

function handler (req, res) {
  // fs.readFile(__dirname + '/index.html',
  // function (err, data) {
  //   if (err) {
  //     res.writeHead(500);
  //     return res.end('Error loading index.html');
  //   }

  //   res.writeHead(200);
  //   res.end(data);
  // });
  res.writeHead(200);
  res.end();
}

io.on('connection', function (socket) {
  socket.on('message', function (data) {
    console.log(data);
    // io.sockets.emit('message', data});
    socket.broadcast.emit('message', 'add_me: ' + data);
  });
});

// io.on('connection', function (socket) {
//   io.emit('this', { will: 'be received by everyone'});

//   socket.on('private message', function (from, msg) {
//     console.log('I received a private message by ', from, ' saying ', msg);
//   });

//   socket.on('disconnect', function () {
//     io.emit('user disconnected');
//   });
// });

