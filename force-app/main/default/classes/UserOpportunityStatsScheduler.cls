global class UserOpportunityStatsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UserOpportunityStatsBatch batch = new UserOpportunityStatsBatch();
        Database.executeBatch(batch, 200);
    }
}
