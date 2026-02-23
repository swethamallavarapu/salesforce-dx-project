public with sharing class BankingOppHelper {
    public static void processAccountInserts(List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Account account : accounts) {
            if (account.Industry != null && account.Industry.equals('Banking')) {
                Opportunity opp = new Opportunity();
                opp.Name = account.Name + ' - Banking Opportunity';
                opp.AccountId = account.Id;
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.today().addDays(30);
                opportunities.add(opp);
            }
        }
        if (!opportunities.isEmpty()) {
            insert opportunities;
        }
    }
}
