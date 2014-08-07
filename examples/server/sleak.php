<?

define('SLEAK_App_Id_Key', 'x-sleak-application-id');
define('SLEAK_Timestamp_Key', 'x-sleak-timestamp');
define('SLEAK_Nonce_Key', 'x-sleak-nonce');
define('SLEAK_Scheme', 'Sleak');

header('Content-Type: application/json');

function array_keys_to_lower($array) {
  $rr = [];
  foreach ($array as $k => $v) {
    $rr[strtolower($k)] = $v;
  }
  return $rr;
}

function normalizeAuthenticationData($authorizationData) {
  return str_replace(['<', '>'], '', $authorizationData);
}

function normalizeAuthenticationInfo($authInfo) {
  $infoDictionary = [];
  foreach ($authInfo as $authPiece) {
    $parts = explode('=', $authPiece);
    $key = trim(array_shift($parts));
    $value = trim(str_replace('"', '', array_shift($parts)));
    $infoDictionary[$key] = $value;
  }
  return $infoDictionary;
}

function normalizeParameterData($array) {
  foreach ($array as $k => $v) {
      if (preg_match('/([^a-zA-Z0-9\-\_])/', $k)) {
        unset($array[$k]);
      } else if ($v === 0) {
        $array[$k] = false;
      }
    }
    return $array;
}

function printSleakError($message, $code) {
  print json_encode(['http_meta' =>
                      ['code' => 401, 'message' => 'Unauthorized'],
                    'error' =>
                      ['type' => 'sleak-error', 'code' => $code, 'message' => $message]]);
  exit;
}

function handleSleakAuth($completeAuthHeader, $applicationId) {

    $authHeaderParts = explode(',', $completeAuthHeader);
    $authHeader = array_shift($authHeaderParts);

    $authInfoDictionary = normalizeAuthenticationInfo($authHeaderParts);

    $authParts = explode(' ', $authHeader);
    $scheme = array_shift($authParts);

    $nonce = $authInfoDictionary['auth_nonce'];
    $timestamp = $authInfoDictionary['auth_timestamp'];

    $nonceAlreadyExists = false; // check to see if nonce and timestamp is already present

    if ($nonceAlreadyExists) {
      return printSleakError('Invalid Request', 'already_used');
    } else {
      // insert nonce/timestamp into DB
    }

    $authData = normalizeAuthenticationData(implode('', $authParts));

    $privateKey = ''; // look up private key from somewhere using the applicationId

    $params = normalizeParameterData($_GET);
    ksort($params);
    $params[SLEAK_App_Id_Key] = $applicationId;
    $params[SLEAK_Timestamp_Key] = $timestamp;
    $params[SLEAK_Nonce_Key] = $nonce;

    $paramString = http_build_query($params);
    $hmacData = hash_hmac('sha256', $paramString, $privateKey);
    if ($authData !== $hmacData) {
      return printSleakError('Invalid Digest', 'invalid_digest');
    } else {
      // Successful. Execute Command
      print 'Success';
    }
}

handleSleakAuth(
  array_keys_to_lower(getallheaders())['authorization'],
  array_keys_to_lower(getallheaders())[SLEAK_App_Id_Key]
  );