public class AWSRemoteSiteScheduleSetup {

    public static void schedule15MinJob() {

        // Abort existing jobs with same name (safety)
        for (CronTrigger ct : [
            SELECT Id FROM CronTrigger
            WHERE CronJobDetail.Name LIKE 'AWS_RemoteSite_%'
        ]) {
            System.abortJob(ct.Id);
        }

        // Schedule 4 jobs at 0, 15, 30, 45
        System.schedule('AWS_RemoteSite_00', '0 0 * * * ?', new AWSRemoteSiteScheduler());
        System.schedule('AWS_RemoteSite_15', '0 15 * * * ?', new AWSRemoteSiteScheduler());
        System.schedule('AWS_RemoteSite_30', '0 30 * * * ?', new AWSRemoteSiteScheduler());
        System.schedule('AWS_RemoteSite_45', '0 45 * * * ?', new AWSRemoteSiteScheduler());

        System.debug('✅ AWS Remote Site Scheduler set for every 15 minutes.');
    }
}