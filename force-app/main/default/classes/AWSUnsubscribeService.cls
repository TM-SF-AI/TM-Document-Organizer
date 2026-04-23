@RestResource(urlMapping='/aws/unsubscribe/*')
global without sharing class AWSUnsubscribeService {

    @HttpPost
    global static void receiveUnsubscribe() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String body = req.requestBody.toString();
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(body);
			System.debug('Data ==> '+data);
            String awsCustomerId = (String) data.get('awsCustomerId');
            String status = (String) data.get('subscriptionStatus');

            if (awsCustomerId == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('Missing required field: awsCustomerId');
                return;
            }

            // Query customer
            List<TechnologyMindz__AWS_Customer__c> customerList = [
                SELECT Id, TechnologyMindz__Subscription_Status__c
                FROM TechnologyMindz__AWS_Customer__c
                WHERE TechnologyMindz__AWS_Customer_Id__c = :awsCustomerId
                LIMIT 1
            ];
			System.debug('customer List ==>'+customerList);
            // Handle not found
            if (customerList.isEmpty()) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(
                    'No AWS customer record found for Id: ' + awsCustomerId
                );
                return;
            }

            TechnologyMindz__AWS_Customer__c customer = customerList[0];

            // Update fields
            customer.TechnologyMindz__Subscription_Status__c = status;
            customer.TechnologyMindz__Unsubscribe_Date__c = System.now();

            update customer;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serializePretty(new Map<String, Object>{
                    'success' => true,
                    'message' => 'Unsubscribe event processed successfully',
                    'recordId' => customer.Id
                })
            );

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}