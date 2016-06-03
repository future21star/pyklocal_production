// Declare required packages and initiate redis pub-sub clients
var io = require('socket.io').listen(5000),
    redisAdapter = require('socket.io-redis'),
  	redis = require('redis'),
    redisClient = redis.createClient(6379, 'localhost'),
    subscriber = redis.createClient(6379, 'localhost');

// io.adapter(redisAdapter({pubClient: redisClient, subClient: subscriber}));

// Ativated if redis client publish any message
subscriber.on("message", function(channel, message) {
  message = JSON.parse(message)
  console.log(JSON.stringify(message));
  io.to(message.project_id).emit(channel, message);
});

io.on('connection', function(socket){
  
  socket.on('getAllUsers', function(cb) {
  });  

});

subscriber.subscribe("listOrder");