// Schedule job every day at 11 AM
// Use this in Anonymous Apex or via UI
String cronExp = '0 20 11 * * ?'; // 11 AM every day
System.schedule('Daily User Opportunity Stats', cronExp, new UserOpportunityStatsScheduler());
