public class OpportunityTriggerHandler {
    public static void beforeUpdate(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            if (opp.StageName == 'Product & Quote Approval' && opp.StageName != oldMap.get(opp.Id).StageName) {
                    opp.addError('Please save the record before submitting for approval.');
            }
        }
    }
    
    public static void afterInsert(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<Opportunity> opptyList = new List<Opportunity>();
        for (Opportunity opp : newList) {
            if(opp.Product_Name__c != null){
                opptyList.add(opp);
            }
        }
        OpportunityTriggerHandlerHelper.createPreCase(opptyList);
    }

    public static void afterUpdate(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            // Submit for first approval if stage is 'Product and Quote Approval'
            if (opp.StageName == 'Product and Quote Approval' && oldOpp.StageName != 'Product and Quote Approval') {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('First level of approval');
                req.setNextApproverIds(new Id[] { '0050T000004wDCXQA2' });
                req.setObjectId(opp.id);
                approvalRequests.add(req);
            }

            // Submit for second approval if the first approval is completed
            if (opp.PPIC_Approval__c == true && oldOpp.PPIC_Approval__c == false) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Second level of Approval');
                req.setObjectId(opp.id);
                approvalRequests.add(req);
            }
        }

        if (!approvalRequests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(approvalRequests);
            for (Approval.ProcessResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Approval process submitted successfully for Opportunity: ' + result.getInstanceId());
                } else {
                    System.debug('Failed to submit approval process for Opportunity: ' + result.getInstanceId());
                }
            }
        }
    }
     public static void validateOpportunityUpdate(List<Opportunity> opportunities) {
        Set<String> restrictedProfiles = new Set<String>{'Sales Exports', 'Sales CDMO'};
         Set<String> restrictedStage = new Set<String>{'Closed Lost', 'Closed Won'};
       
        
        // Get the current user's profile name
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        for (Opportunity opp : opportunities) {
            // Check if the stage is 'Closed Lost' and if the user profile is restricted
            if (restrictedStage.contains(opp.StageName)&& restrictedProfiles.contains(currentUser.Profile.Name)) {
                opp.addError('You cannot edit a Closed Lost Opportunity. Please contact the system admin.');
            }
        }
    }
}