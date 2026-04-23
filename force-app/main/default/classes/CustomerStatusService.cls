@RestResource(urlMapping='/CustomerStatus/*')
global without sharing class CustomerStatusService {
    
    @HttpGet
    global static CustomerResponse getStatus() {
        RestRequest req = RestContext.request;
        String customerId = req.params.get('customerId');
        //String username = req.params.get('username');
        system.debug('customerId 9=='+customerId);
        TechnologyMindz__AWS_Customer__c cust = [
            SELECT Id, TechnologyMindz__Subscription_Status__c 
            FROM TechnologyMindz__AWS_Customer__c 
            WHERE TechnologyMindz__AWS_Customer_Id__c = :customerId 
            LIMIT 1
        ];
        system.debug('cust 16=='+cust);
        
        // Update Username in PBO
        //cust.Username__c = username;
        // update cust;
        
        return new CustomerResponse(
            customerId,
            cust.TechnologyMindz__Subscription_Status__c
        );
    }
    
    global class CustomerResponse {
        public String customerId;
        public String subscriptionStatus;
        public CustomerResponse(String cid, String stat) {
            customerId = cid;
            subscriptionStatus = stat;
        }
    }
}