trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            OpportunityLineItemHandler.handleAfterEvents(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete) {
            OpportunityLineItemHandler.handleAfterEvents(null, Trigger.old);
        }
    }
}