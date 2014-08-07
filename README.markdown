Sleak Auth
==========

A new RESTful authentication protocol.

## Alpha
Sleak is still in the very early alpha stages. I am currently building an app around Sleak. This means Sleak is still changing. Feel free to submit bug reports and pull requests to better improved Sleak.

## Why
OAuth is great, but complicated. There are many OAuth SDKs out there, each one a little different. I wanted to create a simple, but secure, API authentication protocol.

## Design
Sleak is designed to make sure the API request is coming from who they say they are. It is not a way to encrypt or secure the data being sent with the request. Sleak is partially based on this [article](http://www.thebuzzmedia.com/designing-a-secure-rest-api-without-oauth-authentication/).

### Headers
When making an authenticated request to the server, the client includes an `Authorization` header.

The `Authorization` header or "Sleak header" looks something like this:

```
Authorization: Sleak <diget>, auth_nonce="<nonce>", auth_timestamp="<timestamp>"
```

Each request also sends an `x-sleak-application-id` header:

```
x-sleak-application-id: <application-id>
```

## Usage
An example of how to use Sleak.

### Libraries
Here is a list of libraries for Sleak:

1. [SleakPHP](http://github.com/jasonsilberman/sleak-auth/blob/master/SleakPHP) by [Jason Silberman](http://github.com/jasonsilberman). SleakPHP is a sever library written in PHP.

You can also check out some of the included [examples](http://github.com/jasonsilberman/sleak-auth/blob/master/examples/).

### Token Set Up
Each client gets an `application-id` and a `priate-key`. The `application-id` is sent with every request to identify the client. The `private-key` is used to sign the authentication digest.

### Client Code
Here is some of the code required to use Sleak on the client.

#### Auth Digest
The digest sent along with each request is hashed representation of the request params, application id, timestamp, and nonce.

Before being hashed, it might look something like this:

```
q=watch+companies&type=search&x-sleak-application-id=23djiau3ajad83&x-sleak-timestamp=1407374009&x-sleak-nonce=ajDkeaXi
```

Recreating this is pretty simple, here it is in PHP:

```php
$params = array('type' => 'search', 'q' => 'watch companies');
ksort($params); // sort them alphabetically
$params['x-sleak-application-id'] = APP_ID; // set the application id
$params['x-sleak-timestamp'] = time(); // set the current UTC timestamp
$params['x-sleak-nonce'] = createRandomString(8); // random generate a 8 character string

$unhashedDigest = http_build_query($params); // form encode the params array
```

**Note:** The initial request parameters are alphabetically sorted.

**Note:** The parameters should be `application/x-www-form-urlencoded` according to: [http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1](http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1). 

#### Auth Hashing
Once you have your form encoded request parameters. You need to hash them using your `private-key`. ***They should be hashed using HMAC-SHA256.***

In PHP, it might look like this:

```php
$hmacData = hash_hmac('sha256', $unhashedDigest, PRIVATE_KEY);
```

The result of the HMAC hash would be sent as the `<digest>`. The same `timestamp` and `nonce` used in the parameters creation, but sent as `auth_timestamp` and `auth_nonce` respectively.

### Server Code
When the server receives the request from the client. It will collect the request parameters. Then using the `x-sleak-application-id` header look up the `private-key`. Once it has fetched the `private-key`, then it will re-combine the parameters in the same way the client did (alphabetically sorted, then app id, then timestamp, then nonce).

Next, the server will look up the nonce and timestamp, to make sure they have not been used before. If they have been used, it will reject (see "[Error Handling](#error-handling)") the request. If they are new, it will insert them into the look up table (probably a database) and continue with the request.

After we have our parameters and we know the request has not been already submitted, we will form encode the parameters. Then the server will HMAC-SHA256 hash the parameters using the previously looked up the `private-key`.

The last step is comparing the server generated digest and the one provided in the `Authorization` header. If they are the same, the server will continue and execute the request, otherwise it will reject the request.

### Error Handling
If the request is invalid, the server will return an error. It might look something like this:

```json
{
  "http_meta" : {
    "code" : 401,
    "message" : "Unauthorized"
  },
  "error" : {
    "type" : "sleak-error",
    "code" : "invalid_digest",
    "message" : "The digest you provided was not valid."
  }
}
```

*The `erorr.message` can be anything you want.*

#### Error Codes

Here are some error codes you should return:

| Code | Meaning |
|------|---------|
| invalid_digest | The digest the server generated was the not same one the client provided. |
| already_used | The nonce and token sent in the request have already been used. |

## Contributing
If you see a security hole or want to add something, please submit a pull request.

## License
Sleak is licensed under the MIT license (see [LICENSE](http://github.com/jasonsilberman/sleak-auth/blob/master/LICENSE)).