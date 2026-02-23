trigger AccountTrigger on Account (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        BankingOppHelper.processAccountInserts(Trigger.new);
    }
}
