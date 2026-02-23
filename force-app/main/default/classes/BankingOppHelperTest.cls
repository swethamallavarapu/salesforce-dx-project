@isTest
public class BankingOppHelperTest {
    @isTest
    static void testProcessAccountInserts() {
        // Create test Account
        Account acc = new Account(Name = 'Test Bank', Industry = 'Banking');
        insert acc;

        // Query Opportunity
        Opportunity opp = [SELECT Name, AccountId, StageName, CloseDate FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        System.assertEquals(acc.Name + ' - Banking Opportunity', opp.Name);
        System.assertEquals('Prospecting', opp.StageName);
        System.assertEquals(acc.Id, opp.AccountId);
        System.assertEquals(Date.today().addDays(30), opp.CloseDate);
    }

    @isTest
    static void testNoOpportunityForNonBanking() {
        Account acc = new Account(Name = 'Test NonBank', Industry = 'Retail');
        insert acc;
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id];
        System.assertEquals(0, opps.size());
    }
}
