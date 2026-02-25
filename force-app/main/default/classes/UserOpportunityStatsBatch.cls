public class UserOpportunityStatsBatch implements Database.Batchable<SObject>, Database.Stateful {
    public String query;
    public UserOpportunityStatsBatch() {
        // Only retrieve users with standard profiles (update as needed for your org)
        query = 'SELECT Id, Opportunities_Won_in_the_Current_Year__c, Opportunities_lost_in_the_Current_Year__c, Opportunities_Opened_in_the_Current_Year__c, ProfileId, IsActive FROM User WHERE IsActive = true AND Profile.Name IN (\'Standard User\', \'System Administrator\')';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<User> users) {
        Map<Id, Integer> wonMap = new Map<Id, Integer>();
        Map<Id, Integer> lostMap = new Map<Id, Integer>();
        Map<Id, Integer> openedMap = new Map<Id, Integer>();

        List<Opportunity> opps = [SELECT Id, OwnerId, StageName, CloseDate FROM Opportunity WHERE CloseDate = THIS_YEAR];
        for (Opportunity opp : opps) {
            // Count all opened this year
            openedMap.put(opp.OwnerId, openedMap.get(opp.OwnerId) == null ? 1 : openedMap.get(opp.OwnerId) + 1);
            if (opp.StageName == 'Closed Won') {
                wonMap.put(opp.OwnerId, wonMap.get(opp.OwnerId) == null ? 1 : wonMap.get(opp.OwnerId) + 1);
            } else if (opp.StageName == 'Closed Lost') {
                lostMap.put(opp.OwnerId, lostMap.get(opp.OwnerId) == null ? 1 : lostMap.get(opp.OwnerId) + 1);
            }
        }

        for (User u : users) {
            Integer won = wonMap.get(u.Id);
            Integer lost = lostMap.get(u.Id);
            Integer opened = openedMap.get(u.Id);
            Boolean changed = false;
            if (u.Opportunities_Won_in_the_Current_Year__c != (won == null ? 0 : won)) {
                u.Opportunities_Won_in_the_Current_Year__c = won == null ? 0 : won;
                changed = true;
            }
            if (u.Opportunities_lost_in_the_Current_Year__c != (lost == null ? 0 : lost)) {
                u.Opportunities_lost_in_the_Current_Year__c = lost == null ? 0 : lost;
                changed = true;
            }
            if (u.Opportunities_Opened_in_the_Current_Year__c != (opened == null ? 0 : opened)) {
                u.Opportunities_Opened_in_the_Current_Year__c = opened == null ? 0 : opened;
                changed = true;
            }
            if (changed && u.ProfileId != null && u.IsActive) {
                try {
                    update u;
                } catch (DmlException e) {
                    System.debug('Skipped user ' + u.Id + ' (' + u.ProfileId + '): ' + e.getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optionally send notification or log
    }
}
