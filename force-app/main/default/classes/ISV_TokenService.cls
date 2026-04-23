public class ISV_TokenService {
    public class TokenResponse {
        public String access_token;
        public String refresh_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String signature;
    }

    // Exchange the "code" for tokens
    public static TokenResponse exchangeCodeForToken(String code) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ISV_OAuthSettings.loginUrl + '/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=authorization_code'
            + '&code=' + EncodingUtil.urlEncode(code, 'UTF-8')
            + '&client_id=' + EncodingUtil.urlEncode(ISV_OAuthSettings.clientId, 'UTF-8')
            + '&client_secret=' + EncodingUtil.urlEncode(ISV_OAuthSettings.clientSecret, 'UTF-8')
            + '&redirect_uri=' + EncodingUtil.urlEncode(ISV_OAuthSettings.redirectUri, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            system.debug('res.getBody() == ' + res.getBody());
            return (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
        } else {
            System.debug('Token exchange failed: ' + res.getStatus() + ' - ' + res.getBody());
            throw new CalloutException('Token exchange failed: ' + res.getStatus());
        }
    }

    // Use refresh_token to get a new access_token
    public static TokenResponse refreshAccessToken(String refreshToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ISV_OAuthSettings.loginUrl + '/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=refresh_token'
            + '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8')
            + '&client_id=' + EncodingUtil.urlEncode(ISV_OAuthSettings.clientId, 'UTF-8')
            + '&client_secret=' + EncodingUtil.urlEncode(ISV_OAuthSettings.clientSecret, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
        } else {
            System.debug('Refresh token failed: ' + res.getStatus() + ' - ' + res.getBody());
            throw new CalloutException('Refresh token failed: ' + res.getStatus());
        }
    }

    // Parse orgId and userId from "id" URL (e.g., https://login.salesforce.com/id/ORGID/USERID)
    public class IdParts {
        public String orgId;
        public String userId;
    }

    public static IdParts extractIdsFromIdentityUrl(String idUrl) {
        IdParts result = new IdParts();
        List<String> parts = idUrl != null ? idUrl.split('/') : new List<String>();

        if (parts.size() >= 3) {
            // last two segments are orgId and userId
            result.userId = parts[parts.size() - 1];
            result.orgId  = parts[parts.size() - 2];
        }
        return result;
    }
    
    
    
    
     // Generic method to call an org by its Org_Id__c
    public static HttpResponse callout(
        String orgId,
        String method,
        String relativePath, // e.g. '/services/data/v61.0/sobjects/Account'
        String bodyJson
    ) {
        AWS_Customer__c cfg = [
            SELECT Id, Org_Id__c, Customer_Org_Instance_Url__c, Customer_Org_Access_Token__c, Customer_Org_Refresh_Token__c
            FROM AWS_Customer__c
            WHERE Org_Id__c = :orgId
            LIMIT 1
        ];

        if (String.isBlank(cfg.Customer_Org_Refresh_Token__c)) {
            throw new CalloutException('No refresh token stored for org ' + orgId);
        }

        // Ensure we have a valid access token, refresh if necessary
        String accessToken = cfg.Customer_Org_Access_Token__c;
        if (String.isBlank(accessToken)) {
            accessToken = refreshAndStoreAccessToken(cfg);
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(cfg.Customer_Org_Instance_Url__c + relativePath);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        if (!String.isBlank(bodyJson) && method != 'GET') {
            req.setBody(bodyJson);
        }

        Http http = new Http();
        HttpResponse res = http.send(req);

        // If token expired, refresh once and retry
        if (res.getStatusCode() == 401) {
            accessToken = refreshAndStoreAccessToken(cfg);

            req.setHeader('Authorization', 'Bearer ' + accessToken);
            res = http.send(req);
        }

        return res;
    }

    private static String refreshAndStoreAccessToken(AWS_Customer__c cfg) {
        ISV_TokenService.TokenResponse refreshed =
            ISV_TokenService.refreshAccessToken(cfg.Customer_Org_Refresh_Token__c);

        cfg.Customer_Org_Access_Token__c  = refreshed.access_token;
        cfg.Customer_Org_Instance_Url__c  = refreshed.instance_url;
       // cfg.Last_Connected__c = System.now();
        update cfg;

        return cfg.Customer_Org_Access_Token__c;
    }
}