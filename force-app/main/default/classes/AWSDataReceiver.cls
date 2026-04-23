@RestResource(urlMapping='/aws/receiveData/*')
global with sharing class AWSDataReceiver {
    
    /**
* Handles POST requests from external systems (e.g., AWS Marketplace)
* Expected JSON Payload:
* {
*   "awsCustomerId": "cust-123",
*   "awsAccountId": "9876543210",
*   "productCode": "prod-xyz123",
*   "subscriptionStatus": "Active",
*   "zipCode": "110001",
*   "phoneNumber": "9999999999",
*   "companyInformation": "TechMindz Pvt Ltd",
*   "email": "customer@example.com",
* }
*/
    @HttpPost
    global static void receiveAWSData() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Parse the incoming JSON body
            String body = req.requestBody.toString();
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(body);
            
            // Validate required fields
            if (data.get('awsCustomerId') == null || data.get('productCode') == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('Missing required fields: awsCustomerId or productCode');
                return;
            }
            
            // Create a new record every time
            TechnologyMindz__AWS_Customer__c record = new TechnologyMindz__AWS_Customer__c();
            
            record.Name = 'AWS Customer - ' + (String) data.get('name');
            record.TechnologyMindz__AWS_Customer_Id__c = (String) data.get('awsCustomerId');
            record.TechnologyMindz__AWS_Account_Id__c = (String) data.get('awsAccountId');
            record.TechnologyMindz__Product_Code__c = (String) data.get('productCode');
            record.TechnologyMindz__Subscription_Status__c = (String) data.get('subscriptionStatus');
            record.TechnologyMindz__Zip_Code__c = (String) data.get('zipCode');
            
            if (data.get('phoneNumber') != null) {
                try {
                    record.TechnologyMindz__Phone_Number__c = (String) data.get('phoneNumber');
                } catch (Exception ex) {
                    record.TechnologyMindz__Phone_Number__c = null;
                }
            }
            
            record.TechnologyMindz__Company_Information__c = (String) data.get('companyInformation');
            record.TechnologyMindz__Email__c = (String) data.get('email');
            //record.TechnologyMindz__Product_Setup_Preferences__c = (String) data.get('productSetupPreferences');
            record.TechnologyMindz__Registration_Date__c = System.now();
            
            insert record;
            System.debug('Record Inserted : '+ record );
            
            
            // Call separated email method
            sendWelcomeEmail(record);
            
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(
                JSON.serializePretty(new Map<String, Object>{
                    'success' => true,
                        'message' => 'AWS customer record created successfully',
                        'recordId' => record.Id
                        })
            );
            
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serializePretty(new Map<String, Object>{
                    'success' => false,
                        'error' => e.getMessage()
                        })
            );
            logException(e, ' ', ' ');
        }
    }
    
    public static void logException(
        Exception e,
        String className,
        String methodName
    ) {
        try {
            Exception_Log__c log = new Exception_Log__c();
            log.Error_Message__c      = e.getMessage() + ' Stack trace ' + e.getStackTraceString() ;
            // log.Stack_Trace__c  = e.getStackTraceString();
            // log.Class_Name__c   = className;
            // log.Method_Name__c  = methodName;
            // log.Line_Number__c  = e.getLineNumber();
            
            insert log;
        } catch (Exception ex) {
            // Prevent recursive failure
            System.debug('Failed to log exception: ' + ex.getMessage());
        }
    }
    
    
    private static void sendWelcomeEmail(
        TechnologyMindz__AWS_Customer__c customer
    ) {
        if (customer == null || customer.TechnologyMindz__Email__c == null) {
            return;
        }
        
        // 🔐 Installation URLs (hidden behind buttons)
        String prodInstallUrl = 'https://login.salesforce.com/packaging/installPackage.apexp?p0=XXXXXXXXX';
        String sandboxInstallUrl = 'https://test.salesforce.com/packaging/installPackage.apexp?p0=XXXXXXXXX';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(
            new List<String>{ customer.TechnologyMindz__Email__c }
        );
        
        mail.setSubject('AWS Marketplace Subscription Successful');
        
        String htmlBody =
            '<html><body style="font-family:Arial, sans-serif;">' +
            '<p><b>Congratulations!</b> You have successfully subscribed to our ' +
            'application from <b>AWS Marketplace</b>.</p>' +
            
            '<p>Please choose how you want to install the application:</p>' +
            
            '<p>' +
            '<a href="' + prodInstallUrl + '" ' +
            'style="background:#0070d2;color:white;padding:10px 16px;' +
            'text-decoration:none;border-radius:4px;margin-right:10px;">' +
            'Install to Production</a>' +
            
            '<a href="' + sandboxInstallUrl + '" ' +
            'style="background:#6a6a6a;color:white;padding:10px 16px;' +
            'text-decoration:none;border-radius:4px;">' +
            'Install in Sandbox</a>' +
            '</p>' +
            
            '<p><b>Your Customer ID:</b> ' +
            customer.TechnologyMindz__AWS_Customer_Id__c + '</p>' +
            
            '<p>Thank you for choosing <b>TechnologyMindz</b>.</p>' +
            '</body></html>';
        
        mail.setHtmlBody(htmlBody);
        
        Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ mail }
        );
    }
}