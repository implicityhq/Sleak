var crypto = require('crypto');

var APP_ID = '23djiau3ajad83';
var PRIVATE_KEY = 'asd3jsdfkHKSJHkq3234dkfajh3kajsdfkjah';

function queryStringValue(object) {
  var pairs = [];
  for (var key in object) {
    if (object.hasOwnProperty(key)) {
      var value = encodeURIComponent(object[key]);
      value = value.replace('%20', '+');
      pairs.push(key + '=' + value);
    }
  }
  return pairs.join('&');
}

function createRandomString(len) {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

  for(var i=0; i < len; i++) {
    text += possible.charAt(Math.floor(Math.random() * possible.length));
  }

  return text;
}

var timestamp = Math.floor(Date.now() / 1000),
    nonce = createRandomString(8);

var unPparams = {'type' : 'search', 'q' : 'watch companies'};
var params = {};
Object.keys(unPparams)
      .sort()
      .forEach(function(v, i) {
          params[v] = unPparams[v];
       });
params['x-sleak-application-id'] = APP_ID;
params['x-sleak-timestamp'] = timestamp;
params['x-sleak-nonce'] = nonce;

console.log(params);
console.log(queryStringValue(params));
var hash = crypto.createHmac('sha256', PRIVATE_KEY).update(queryStringValue(params)).digest('hex');
console.log(hash);

var authHeader = 'Authorization: Sleak';
authHeader += ' ' + hash;
authHeader += ', auth_nonce="' + nonce + '", auth_timestamp="' + timestamp + '"';

console.log(authHeader);