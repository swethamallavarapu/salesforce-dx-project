@isTest
public class UserOpportunityStatsBatchTest {
    @isTest
    static void testBatchWithStandardUser() {
        // Create a test profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // Create test user
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        // Create opportunities for this user
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name='Opp Won', StageName='Closed Won', CloseDate=Date.today(), OwnerId=u.Id),
            new Opportunity(Name='Opp Lost', StageName='Closed Lost', CloseDate=Date.today(), OwnerId=u.Id),
            new Opportunity(Name='Opp Pipeline', StageName='Prospecting', CloseDate=Date.today(), OwnerId=u.Id)
        };
        insert opps;

        Test.startTest();
        UserOpportunityStatsBatch batch = new UserOpportunityStatsBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Reload user
        User updatedUser = [SELECT Opportunities_Won_in_the_Current_Year__c, Opportunities_lost_in_the_Current_Year__c, Opportunities_Opened_in_the_Current_Year__c FROM User WHERE Id = :u.Id];
        System.assertEquals(1, updatedUser.Opportunities_Won_in_the_Current_Year__c, 'Won count should be 1');
        System.assertEquals(1, updatedUser.Opportunities_lost_in_the_Current_Year__c, 'Lost count should be 1');
        System.assertEquals(3, updatedUser.Opportunities_Opened_in_the_Current_Year__c, 'Opened count should be 3');
    }

    @isTest
    static void testBatchWithNoOpportunities() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'NoOpp',
            LastName = 'User',
            Email = 'nooppuser@example.com',
            Username = 'nooppuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'nuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        Test.startTest();
        UserOpportunityStatsBatch batch = new UserOpportunityStatsBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        User updatedUser = [SELECT Opportunities_Won_in_the_Current_Year__c, Opportunities_lost_in_the_Current_Year__c, Opportunities_Opened_in_the_Current_Year__c FROM User WHERE Id = :u.Id];
        System.assertEquals(0, updatedUser.Opportunities_Won_in_the_Current_Year__c, 'Won count should be 0');
        System.assertEquals(0, updatedUser.Opportunities_lost_in_the_Current_Year__c, 'Lost count should be 0');
        System.assertEquals(0, updatedUser.Opportunities_Opened_in_the_Current_Year__c, 'Opened count should be 0');
    }
}
