// Declare required packages and initiate redis pub-sub clients
var io = require('socket.io').listen(5000),
    redisAdapter = require('socket.io-redis'),
  	redis = require('redis'),
    redisClient = redis.createClient(6379, 'localhost'),
    subscriber = redis.createClient(6379, 'localhost');

// Uncomment below line if only required
// io.adapter(redisAdapter({pubClient: redisClient, subClient: subscriber}));

// Activated if redis client publish any message
subscriber.on("message", function(channel, message) {
  message = JSON.parse(message);
  console.log(message);

  // Emit an event that will be listened by angular controller
  // 'message' will contain all the data sent from backend to angular
  // use following code in angular in order to listen this event

 	// socket.on("eventName", function(data){
	// 	perform anything with data
	// })

  io.emit("eventName",message);
});

// Subascribe redis client for a channel
// The same name will be used from backend while sending data
subscriber.subscribe("listUpdate");
console.log('I am listening SUCKERS');