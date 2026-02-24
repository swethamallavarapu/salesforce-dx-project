@isTest
public class OpportunityLineItemHandlerTest {

    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Product2 prod1 = new Product2(Name = 'Product 1', IsActive = true);
        Product2 prod2 = new Product2(Name = 'Product 2', IsActive = true);
        insert new List<Product2>{prod1, prod2};

        Id stdPbId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod1.Id,
            UnitPrice = 100,
            IsActive = true
        );

        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod2.Id,
            UnitPrice = 200,
            IsActive = true
        );

        insert new List<PricebookEntry>{pbe1, pbe2};
    }

    @isTest
    static void testInsertUpdateDeleteOLI() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1' LIMIT 1];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2' LIMIT 1];

        Id stdPbId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = [
            SELECT Id FROM PricebookEntry 
            WHERE Product2Id = :prod1.Id 
            AND Pricebook2Id = :stdPbId 
            LIMIT 1
        ];

        PricebookEntry pbe2 = [
            SELECT Id FROM PricebookEntry 
            WHERE Product2Id = :prod2.Id 
            AND Pricebook2Id = :stdPbId 
            LIMIT 1
        ];

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Pricebook2Id = stdPbId
        );
        insert opp;

        // INSERT OLI
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe1.Id,
            TotalPrice = 100
        );
        insert oli;

        Product2 prod1After = [
            SELECT Opportunity_Pipeline__c, Opportunity_Won__c, Opportunity_Lost__c
            FROM Product2 WHERE Id = :prod1.Id
        ];
        System.assertEquals(1, prod1After.Opportunity_Pipeline__c);

        // UPDATE TO CLOSED WON
        opp.StageName = 'Closed Won';
        update opp;

        prod1After = [
            SELECT Opportunity_Pipeline__c, Opportunity_Won__c, Opportunity_Lost__c
            FROM Product2 WHERE Id = :prod1.Id
        ];
        System.assertEquals(1, prod1After.Opportunity_Won__c);

        // UPDATE TO CLOSED LOST
        opp.StageName = 'Closed Lost';
        update opp;

        prod1After = [
            SELECT Opportunity_Pipeline__c, Opportunity_Won__c, Opportunity_Lost__c
            FROM Product2 WHERE Id = :prod1.Id
        ];
        System.assertEquals(1, prod1After.Opportunity_Lost__c);

        // DELETE
        delete oli;

        prod1After = [
            SELECT Opportunity_Pipeline__c, Opportunity_Won__c, Opportunity_Lost__c
            FROM Product2 WHERE Id = :prod1.Id
        ];
        System.assertEquals(0, prod1After.Opportunity_Pipeline__c);
        System.assertEquals(0, prod1After.Opportunity_Won__c);
        System.assertEquals(0, prod1After.Opportunity_Lost__c);
    }

    @isTest
    static void testBulkUpdateOpportunities() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1' LIMIT 1];

        Id stdPbId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = [
            SELECT Id FROM PricebookEntry 
            WHERE Product2Id = :prod1.Id 
            AND Pricebook2Id = :stdPbId 
            LIMIT 1
        ];

        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 0; i < 5; i++) {
            opps.add(new Opportunity(
                Name = 'Bulk Opp ' + i,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Pricebook2Id = stdPbId
            ));
        }

        insert opps;

        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

        for (Opportunity opp : opps) {
            olis.add(new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 1,
                PricebookEntryId = pbe1.Id,
                TotalPrice = 100
            ));
        }

        insert olis;

        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }

        update opps;

        Product2 prod1After = [
            SELECT Opportunity_Pipeline__c, Opportunity_Won__c, Opportunity_Lost__c
            FROM Product2 WHERE Id = :prod1.Id
        ];

        System.assertEquals(5, prod1After.Opportunity_Won__c);
    }
}