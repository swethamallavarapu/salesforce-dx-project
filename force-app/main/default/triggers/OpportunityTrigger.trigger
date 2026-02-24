trigger OpportunityTrigger on Opportunity (after update) {
    // Only process if StageName changed
    Set<Id> changedOppIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if (opp.StageName != oldOpp.StageName) {
            changedOppIds.add(opp.Id);
        }
    }
    if (!changedOppIds.isEmpty()) {
        OpportunityLineItemHandler.handleOpportunityStageChange(changedOppIds);
    }
}