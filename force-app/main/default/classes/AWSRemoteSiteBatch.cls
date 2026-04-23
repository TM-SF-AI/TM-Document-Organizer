global class AWSRemoteSiteBatch 
implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<Id> processedCustomerIds = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, TechnologyMindz__AWS_Customer_Id__c,
            TechnologyMindz__Customer_Org_Instance_Url__c,
            TechnologyMindz__Remote_Site_Created__c,
            TechnologyMindz__Customer_Org_Access_Token__c
            FROM TechnologyMindz__AWS_Customer__c
            WHERE TechnologyMindz__Remote_Site_Created__c = false
            AND TechnologyMindz__Customer_Org_Instance_Url__c != null
            //AND ID = 'a03GC00007jOuY1YAK'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<AWS_Customer__c> scope) {
        
        List<TechnologyMindz__AWS_Customer__c> updateList = new List<TechnologyMindz__AWS_Customer__c>();
        
        for (TechnologyMindz__AWS_Customer__c c : scope) {
            try {
                AWSRemoteSiteCreator.createForCustomer(c);
                c.TechnologyMindz__Remote_Site_Created__c = true;
                updateList.add(c);
                processedCustomerIds.add(c.Id);
                
            } catch (Exception e) {
                System.debug('Batch Error: ' + e.getMessage());
            }
        }
        
        if (!updateList.isEmpty()) {
            update updateList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch finished. Running Queueable for reconciliation...');
        
        List<TechnologyMindz__AWS_Customer__c> refreshed = [
            SELECT Id, TechnologyMindz__AWS_Customer_Id__c,
            TechnologyMindz__Remote_Site_Created__c,
            TechnologyMindz__Customer_Org_Access_Token__c,
            TechnologyMindz__Customer_Org_Instance_Url__c,
            TechnologyMindz__Subscription_Status__c
            FROM TechnologyMindz__AWS_Customer__c
            WHERE TechnologyMindz__Remote_Site_Created__c = true
            AND SystemModstamp = TODAY
        ];
        
        system.debug('refreshed == ' + refreshed);
        // ✅ Chain the Queueable
        if (!refreshed.isEmpty()) {
            System.enqueueJob(new AWSStatusPushQueueable(refreshed));
        }
    }
}