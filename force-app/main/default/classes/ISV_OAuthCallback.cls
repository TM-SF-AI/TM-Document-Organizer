global without sharing class ISV_OAuthCallback {
    public pageReference OAUthProcessing(){
        String code = ApexPages.currentPage().getParameters().get('code');
        String state = ApexPages.currentPage().getParameters().get('state');
        
        // String instanceURL = ApexPages.currentPage().getParameters().get('instanceURL');
        state =  EncodingUtil.urlDecode(state, 'UTF-8');      
        List<String> stateParts = state.split('#');
        String custId = stateParts[0];
        String instanceURL = stateParts[1];
        
        string redirectURL;
        try {
            // 1) Exchange code for tokens
            ISV_TokenService.TokenResponse tokenResp = ISV_TokenService.exchangeCodeForToken(code);
            
            // 2) Extract org & user from identity URL
            ISV_TokenService.IdParts ids = ISV_TokenService.extractIdsFromIdentityUrl(tokenResp.id);
            
            String orgIdFromIdentity  = ids.orgId;
            String userIdFromIdentity = ids.userId;
            
            // 3) Upsert customer config record by Org_Id__c
            AWS_Customer__c existing = null;
            List<AWS_Customer__c> configs = [
                SELECT Id, Org_Id__c,Customer_Org_Instance_Url__c, Customer_Org_Refresh_Token__c, Customer_Org_Access_Token__c, AWS_Customer_Id__c
                FROM AWS_Customer__c 
                WHERE AWS_Customer_Id__c = :custId
                LIMIT 1
            ];
            system.debug(' existing 22==' + existing);
            
            if (!configs.isEmpty()) {
                existing = configs[0];
                system.debug(' existing 33==' + existing);
            }
            
            if (existing == null) {
                existing = new AWS_Customer__c();
                existing.AWS_Customer_Id__c = custId;
                system.debug(' existing 44==' + existing);
                
            }
            
            existing.Customer_Org_Instance_Url__c   = instanceURL;
            existing.Customer_Org_Refresh_Token__c  = tokenResp.refresh_token;
            existing.Customer_Org_Access_Token__c   = tokenResp.access_token; 
            upsert existing AWS_Customer_Id__c;
            
            // 4) Show a simple success message in browser
            redirectURL = instanceURL + '/lightning/n/DownloadManager__Download_Manager_LWC';
        } catch (Exception e) {
            System.debug('Error handling OAuth callback: ' + e.getMessage());

        }
        return new pageReference(redirectURL);
    }
    
}