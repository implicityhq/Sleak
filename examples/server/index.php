<?

error_reporting(E_ALL);
ini_set('display_errors', true);

header('Content-Type: application/json');

require_once dirname(__FILE__) . '/../../SleakPHP/Sleak.php';

define('PRIVATE_KEY', 'tGupPBruGcAj87LtP6YzVeYGg2vZH96yA6BXEqHJip2dfM83Kh'); // You should randomly create these

function puts($status, $error = null, $message = null) {
	$packet = ['http_meta' => ['code' => 200, 'message' => 'OK']];
	$packet['status'] = $status;
	if ($error) {
		$packet['error'] = ['type' => 'sleak-error', 'code' => $error, 'message' => $message];
	}
	print json_encode($packet);
}

$sleak = new Sleak();

$sleak->setPrivateKeyLookupCallback(function ($applicationId) {
  return PRIVATE_KEY; // look up private key using $applicationId
});
$sleak->setFetchReplayCallback(function ($nonce, $timestamp) {
  return false; // run check to see if $nonce/$timestamp have been used before
});
$sleak->setInsertReplayCallback(function ($nonce, $timestamp) {
  // insert $nonce/$timestamp into DB somewhere
});

$sleakResponse = $sleak->run(false); // true if Sleak should throw exceptions

if ($sleakResponse->ok === true) {
  puts('success');
} else {
  // Sleak auth failed
  puts('failed', $sleakResponse->errorCode, $sleakResponse->message);
}