@isTest
public class UserOpportunityStatsSchedulerTest {
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 12 * * ?'; // Noon, just for test
        String jobId = System.schedule('Test User Opp Stats Scheduler', cronExp, new UserOpportunityStatsScheduler());
        System.assertNotEquals(null, jobId, 'Scheduled jobId should not be null');
        Test.stopTest();
    }
}
