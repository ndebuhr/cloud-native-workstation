ACCESSTOKEN=$(curl http://keycloak:8080/auth/realms/master/protocol/openid-connect/token \
  -d "username=$USERNAME&password=$PASSWORD&grant_type=password&client_id=admin-cli" | jq .access_token | sed 's/"//g')

echo $ACCESSTOKEN

curl -vv -X POST "http://keycloak:8080/auth/admin/realms/master/clients" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ACCESSTOKEN" \
  -H "Content-Type: application/json" \
  -d "
{
    \"id\": \"$1\",
    \"clientId\": \"$1\",
    \"rootUrl\": \"http://$1:$2\",
    \"adminUrl\": \"http://$1:$2\",
    \"surrogateAuthRequired\": false,
    \"enabled\": true,
    \"clientAuthenticatorType\": \"client-secret\",
    \"secret\": \"$SECRET\",
    \"redirectUris\": [
        \"*\"
    ],
    \"webOrigins\": [
        \"http://$1:$2\"
    ],
    \"notBefore\": 0,
    \"bearerOnly\": false,
    \"consentRequired\": false,
    \"standardFlowEnabled\": true,
    \"implicitFlowEnabled\": false,
    \"directAccessGrantsEnabled\": true,
    \"serviceAccountsEnabled\": false,
    \"publicClient\": false,
    \"frontchannelLogout\": false,
    \"protocol\": \"openid-connect\",
    \"attributes\": {
      \"saml.assertion.signature\": \"false\",
      \"saml.force.post.binding\": \"false\",
      \"saml.multivalued.roles\": \"false\",
      \"saml.encrypt\": \"false\",
      \"saml.server.signature\": \"false\",
      \"saml.server.signature.keyinfo.ext\": \"false\",
      \"exclude.session.state.from.auth.response\": \"false\",
      \"saml_force_name_id_format\": \"false\",
      \"saml.client.signature\": \"false\",
      \"tls.client.certificate.bound.access.tokens\": \"false\",
      \"saml.authnstatement\": \"false\",
      \"display.on.consent.screen\": \"false\",
      \"saml.onetimeuse.condition\": \"false\"
    },
    \"authenticationFlowBindingOverrides\": {},
    \"fullScopeAllowed\": true,
    \"nodeReRegistrationTimeout\": -1,
    \"access\": {
      \"view\": true,
      \"configure\": true,
      \"manage\": true
    }
}"

curl -vv -X POST "http://keycloak:8080/auth/admin/realms/master/client-scopes/all/protocol-mappers/models" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ACCESSTOKEN" \
  -H "Content-Type: application/json" \
  -d "
      {
        \"id\": \"$1\",
        \"name\": \"$1\",
        \"protocol\": \"openid-connect\",
        \"protocolMapper\": \"oidc-audience-mapper\",
        \"consentRequired\": false,
        \"config\": {
          \"included.client.audience\": \"$1\",
          \"id.token.claim\": \"true\",
          \"access.token.claim\": \"true\"
        }
      }"

curl -vv -X PUT "http://keycloak:8080/auth/admin/realms/master/clients/$1/default-client-scopes/all" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ACCESSTOKEN" \
  -H "Content-Type: application/json"
