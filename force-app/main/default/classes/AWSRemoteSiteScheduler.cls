global class AWSRemoteSiteScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AWSRemoteSiteBatch(), 10);
    }
}