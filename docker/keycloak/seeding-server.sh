ACCESSTOKEN=$(curl http://keycloak:8080/auth/realms/master/protocol/openid-connect/token \
  -d "username=$USERNAME&password=$PASSWORD&grant_type=password&client_id=admin-cli" | jq .access_token | sed 's/"//g')

echo $ACCESSTOKEN

curl -vv -X PUT "http://keycloak:8080/auth/admin/realms/master" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ACCESSTOKEN" \
  -H "Content-Type: application/json" \
  -d '
{
  "id": "master",
  "realm": "master",
  "displayName": "Keycloak",
  "displayNameHtml": "<div class=\"kc-logo-text\"><span>Keycloak</span></div>",
  "notBefore": 0,
  "revokeRefreshToken": false,
  "refreshTokenMaxReuse": 0,
  "accessTokenLifespan": 2592000,
  "accessTokenLifespanForImplicitFlow": 2592000,
  "ssoSessionIdleTimeout": 2592000,
  "ssoSessionMaxLifespan": 2592000,
  "ssoSessionIdleTimeoutRememberMe": 0,
  "ssoSessionMaxLifespanRememberMe": 0,
  "offlineSessionIdleTimeout": 2592000,
  "offlineSessionMaxLifespanEnabled": false,
  "offlineSessionMaxLifespan": 5184000,
  "accessCodeLifespan": 2592000,
  "accessCodeLifespanUserAction": 2592000,
  "accessCodeLifespanLogin": 2592000,
  "actionTokenGeneratedByAdminLifespan": 2592000,
  "actionTokenGeneratedByUserLifespan": 2592000,
  "enabled": true,
  "sslRequired": "external",
  "registrationAllowed": false,
  "registrationEmailAsUsername": false,
  "rememberMe": false,
  "verifyEmail": false,
  "loginWithEmailAllowed": true,
  "duplicateEmailsAllowed": false,
  "resetPasswordAllowed": false,
  "editUsernameAllowed": false,
  "bruteForceProtected": false,
  "permanentLockout": false,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "waitIncrementSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,
  "failureFactor": 30,
  "defaultRoles": [
    "offline_access",
    "uma_authorization"
  ],
  "requiredCredentials": [
    "password"
  ],
  "otpPolicyType": "totp",
  "otpPolicyAlgorithm": "HmacSHA1",
  "otpPolicyInitialCounter": 0,
  "otpPolicyDigits": 6,
  "otpPolicyLookAheadWindow": 1,
  "otpPolicyPeriod": 30,
  "otpSupportedApplications": [
    "FreeOTP",
    "Google Authenticator"
  ],
  "browserSecurityHeaders": {
    "contentSecurityPolicyReportOnly": "",
    "xContentTypeOptions": "nosniff",
    "xRobotsTag": "none",
    "xFrameOptions": "SAMEORIGIN",
    "xXSSProtection": "1; mode=block",
    "contentSecurityPolicy": "frame-src self; frame-ancestors self; object-src none;",
    "strictTransportSecurity": "max-age=31536000; includeSubDomains"
  },
  "smtpServer": {},
  "eventsEnabled": false,
  "eventsListeners": [
    "jboss-logging"
  ],
  "enabledEventTypes": [],
  "adminEventsEnabled": false,
  "adminEventsDetailsEnabled": false,
  "internationalizationEnabled": false,
  "supportedLocales": [],
  "browserFlow": "browser",
  "registrationFlow": "registration",
  "directGrantFlow": "direct grant",
  "resetCredentialsFlow": "reset credentials",
  "clientAuthenticationFlow": "clients",
  "dockerAuthenticationFlow": "docker auth",
  "attributes": {
    "_browser_header.xXSSProtection": "1; mode=block",
    "_browser_header.strictTransportSecurity": "max-age=31536000; includeSubDomains",
    "_browser_header.xFrameOptions": "SAMEORIGIN",
    "quickLoginCheckMilliSeconds": "1000",
    "permanentLockout": "false",
    "displayName": "Keycloak",
    "_browser_header.xRobotsTag": "none",
    "maxFailureWaitSeconds": "900",
    "displayNameHtml": "<div class=\"kc-logo-text\"><span>Keycloak</span></div>",
    "minimumQuickLoginWaitSeconds": "60",
    "failureFactor": "30",
    "actionTokenGeneratedByUserLifespan": "2592000",
    "maxDeltaTimeSeconds": "43200",
    "_browser_header.xContentTypeOptions": "nosniff",
    "actionTokenGeneratedByAdminLifespan": "2592000",
    "offlineSessionMaxLifespan": "5184000",
    "_browser_header.contentSecurityPolicyReportOnly": "",
    "bruteForceProtected": "false",
    "_browser_header.contentSecurityPolicy": "frame-src self; frame-ancestors self; object-src none;",
    "offlineSessionMaxLifespanEnabled": "false",
    "waitIncrementSeconds": "60"
  },
  "userManagedAccessAllowed": false
}'

curl -vv -X POST "http://keycloak:8080/auth/admin/realms/master/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ACCESSTOKEN" \
  -H "Content-Type: application/json" \
  -d "
  {
    \"id\": \"all\",
    \"name\": \"all\",
    \"protocol\": \"openid-connect\",
    \"attributes\": {
      \"include.in.token.scope\": \"true\",
      \"display.on.consent.screen\": \"true\"
    }
  }"