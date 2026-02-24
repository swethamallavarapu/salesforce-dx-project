public with sharing class OpportunityLineItemHandler {
    // Called when Opportunity stage changes
    public static void handleOpportunityStageChange(Set<Id> oppIds) {
        if (oppIds == null || oppIds.isEmpty()) return;
        // Find all Product2 Ids related to these Opportunities
        Set<Id> productIds = new Set<Id>();
        for (OpportunityLineItem oli : [
            SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppIds AND Product2Id != null
        ]) {
            productIds.add(oli.Product2Id);
        }
        updateProductOpportunityCounts(productIds);
    }

    public static void updateProductOpportunityCounts(Set<Id> productIds) {
        if (productIds == null || productIds.isEmpty()) return;

        // Query all OpportunityLineItems for the given Product2 Ids, including OpportunityId and StageName
        List<OpportunityLineItem> oliList = [
            SELECT Id, OpportunityId, Product2Id, Opportunity.StageName
            FROM OpportunityLineItem
            WHERE Product2Id IN :productIds
        ];

        // For each Product2, count unique Opportunities by their latest StageName
        Map<Id, Map<Id, String>> productToOppStage = new Map<Id, Map<Id, String>>();
        for (OpportunityLineItem oli : oliList) {
            if (!productToOppStage.containsKey(oli.Product2Id)) {
                productToOppStage.put(oli.Product2Id, new Map<Id, String>());
            }
            // Always use the latest Opportunity stage for each OpportunityId
            productToOppStage.get(oli.Product2Id).put(oli.OpportunityId, oli.Opportunity.StageName);
        }

        List<Product2> productsToUpdate = new List<Product2>();
        for (Id productId : productIds) {
            Integer won = 0, lost = 0, pipeline = 0;
            Map<Id, String> oppStageMap = productToOppStage.get(productId);
            if (oppStageMap != null) {
                for (String stage : oppStageMap.values()) {
                    if (stage == 'Closed Won') {
                        won++;
                    } else if (stage == 'Closed Lost') {
                        lost++;
                    } else {
                        pipeline++;
                    }
                }
            }
            productsToUpdate.add(new Product2(
                Id = productId,
                Opportunity_Won__c = won,
                Opportunity_Lost__c = lost,
                Opportunity_Pipeline__c = pipeline
            ));
        }
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }

    public static void handleAfterEvents(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList) {
        Set<Id> productIds = new Set<Id>();
        if (newList != null) {
            for (OpportunityLineItem oli : newList) {
                if (oli.Product2Id != null) productIds.add(oli.Product2Id);
            }
        }
        if (oldList != null) {
            for (OpportunityLineItem oli : oldList) {
                if (oli.Product2Id != null) productIds.add(oli.Product2Id);
            }
        }
        updateProductOpportunityCounts(productIds);
    }
}