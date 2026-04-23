trigger AWSStatusPushTrigger on TechnologyMindz__AWS_Customer__c (after update) {
    List<TechnologyMindz__AWS_Customer__c> toPush = new List<TechnologyMindz__AWS_Customer__c>();

    for (TechnologyMindz__AWS_Customer__c newRec : Trigger.new) {
        TechnologyMindz__AWS_Customer__c oldRec = Trigger.oldMap.get(newRec.Id);

        if (newRec.TechnologyMindz__Subscription_Status__c != oldRec.TechnologyMindz__Subscription_Status__c) {
            toPush.add(newRec);
        }
    }

    if (!toPush.isEmpty()) {
        system.debug('in toPush.isEmpty(');
      //  AWSStatusPushService.pushStatus(toPush);
              System.enqueueJob(new AWSStatusPushQueueable(toPush));

    }
            system.debug('out toPush.isEmpty(');

}