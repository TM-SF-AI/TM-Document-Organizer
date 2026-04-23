/*public class AWSStatusPushQueueable implements Queueable, Database.AllowsCallouts {
    
    private List<TechnologyMindz__AWS_Customer__c> customers;
    
    public AWSStatusPushQueueable(List<TechnologyMindz__AWS_Customer__c> customers) {
        this.customers = customers;
    }
    
    public void execute(QueueableContext context) {
        system.debug('context==');
        for (TechnologyMindz__AWS_Customer__c c : customers) {
            
            try {
                // 1. Ensure token is valid (or refresh it)
                String accessToken = ensureValidAccessToken(c);
                
                // 2. Build endpoint
                String endpoint = c.Customer_Org_Instance_Url__c 
                    + '/services/apexrest/DownloadManager/isv/updateStatus';
                
                // 3. Build request
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                
                Map<String, Object> payload = new Map<String, Object>{
                    'customerId' => c.TechnologyMindz__AWS_Customer_Id__c,
                        'subscriptionStatus' => c.TechnologyMindz__Subscription_Status__c
                        };
                            
                            req.setBody(JSON.serialize(payload));
                
                // 4. Call subscriber org
                HttpResponse res = new Http().send(req);
                System.debug('CALLBACK SUCCESS => ' + res.getBody());
                
                // 5. If token expired, refresh and retry once
                if (res.getStatusCode() == 401) {
                    accessToken = refreshAccessToken(c);
                    req.setHeader('Authorization', 'Bearer ' + accessToken);
                    res = new Http().send(req);
                    System.debug('RETRY AFTER REFRESH => ' + res.getBody());
                }
                
                // update record here
                
            } catch (Exception e) {
                System.debug('CALLBACK ERROR => ' + e.getMessage());
            }
        }
    }
    
    private String ensureValidAccessToken(TechnologyMindz__AWS_Customer__c c) {
        if (String.isBlank(c.Customer_Org_Access_Token__c)) {
            return refreshAccessToken(c);
        }
        return c.Customer_Org_Access_Token__c;
    }
    
    private String refreshAccessToken(TechnologyMindz__AWS_Customer__c c) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        req.setBody(
            'grant_type=refresh_token'
            + '&client_id=' + '3MVG9G9pzCUSkzZspzk03Kc24s0hhWWtlgo0GiIe1pOWNlBhphBbIPUIyWeWFnuPRYaNe8G9fv96ai3RN3l_d'
            + '&client_secret=' + '40F918C4CF9FB34A02EA04DD2C1210D5F949941361AA394ECE385A75EB57D960'
            + '&refresh_token=' + c.Customer_Org_Refresh_Token__c
        );
        
        HttpResponse res = new Http().send(req);
        
        Map<String,Object> resp = 
            (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        
        c.Customer_Org_Access_Token__c = (String) resp.get('access_token');
        c.Customer_Org_Instance_Url__c = (String) resp.get('instance_url');
        update c; // dont do this here
        
        return c.Customer_Org_Access_Token__c; // return both Customer_Org_Instance_Url__c  and Customer_Org_Access_Token__c
    }
} */

public class AWSStatusPushQueueable implements Queueable, Database.AllowsCallouts {

    private List<TechnologyMindz__AWS_Customer__c> customers;
    private List<TechnologyMindz__AWS_Customer__c> customersToUpdate = new List<TechnologyMindz__AWS_Customer__c>();

    public AWSStatusPushQueueable(List<TechnologyMindz__AWS_Customer__c> customers) {
        this.customers = customers.deepClone(true, true); // prevents read-only issues
    }

    public void execute(QueueableContext context) {

        for (TechnologyMindz__AWS_Customer__c c : customers) {

            try {
                // 1. Ensure token
                TokenResponse tokenData = ensureValidAccessToken(c);

                // 2. Build endpoint using refreshed instance URL
                String endpoint = tokenData.instanceUrl +
                    '/services/apexrest/DownloadManager/isv/updateStatus';

                // 3. HTTP request
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer ' + tokenData.accessToken);

                Map<String, Object> payload = new Map<String, Object>{
                    'customerId' => c.TechnologyMindz__AWS_Customer_Id__c,
                    'subscriptionStatus' => c.TechnologyMindz__Subscription_Status__c
                };
                req.setBody(JSON.serialize(payload));

                HttpResponse res = new Http().send(req);

                // Retry if 401 Unauthorized
                if (res.getStatusCode() == 401) {
                    tokenData = refreshAccessToken(c);

                    req.setHeader('Authorization', 'Bearer ' + tokenData.accessToken);
                    res = new Http().send(req);
                }

                // 4. After successful callout → update local record
                c.Customer_Org_Access_Token__c = tokenData.accessToken;
                c.Customer_Org_Instance_Url__c = tokenData.instanceUrl;

                customersToUpdate.add(c);

            } catch (Exception e) {
                System.debug('CALLBACK ERROR => ' + e.getMessage());
            }
        }

        // 5. Update AFTER loop, AFTER all callouts
        if (!customersToUpdate.isEmpty()) {
            update customersToUpdate;
        }
    }

    // ------------------------------
    // TOKEN HANDLING
    // ------------------------------

    private TokenResponse ensureValidAccessToken(TechnologyMindz__AWS_Customer__c c) {
        if (String.isBlank(c.Customer_Org_Access_Token__c)) {
            return refreshAccessToken(c);
        }

        TokenResponse resp = new TokenResponse();
        resp.accessToken = c.Customer_Org_Access_Token__c;
        resp.instanceUrl = c.Customer_Org_Instance_Url__c;
        return resp;
    }

    private TokenResponse refreshAccessToken(TechnologyMindz__AWS_Customer__c c) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        req.setBody(
            'grant_type=refresh_token'
            + '&client_id=3MVG9G9pzCUSkzZspzk03Kc24s0hhWWtlgo0GiIe1pOWNlBhphBbIPUIyWeWFnuPRYaNe8G9fv96ai3RN3l_d'
            + '&client_secret=40F918C4CF9FB34A02EA04DD2C1210D5F949941361AA394ECE385A75EB57D960'
            + '&refresh_token=' + c.Customer_Org_Refresh_Token__c
        );

        HttpResponse res = new Http().send(req);

        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        TokenResponse tokenData = new TokenResponse();
        tokenData.accessToken = (String) resp.get('access_token');
        tokenData.instanceUrl = (String) resp.get('instance_url');

        return tokenData;
    }

    // ------------------------------
    // WRAPPER CLASS
    // ------------------------------
    public class TokenResponse {
        public String accessToken;
        public String instanceUrl;
    }
}