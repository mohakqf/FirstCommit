public with sharing class OpportunityController {
    
    @AuraEnabled(cacheable=true)
    public static String getOpportunities() {
        String userID = UserInfo.getUserId();
        String jsonData;
        string processid;
        Id processDefinitionId = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Approval_Process_for_Opportunity1' LIMIT 1].Id;
        List<ProcessInstance> prsInstance = [Select Id,ProcessDefinitionId,ProcessDefinition.DeveloperName,Status,TargetObjectId from ProcessInstance where ProcessDefinitionId =:processDefinitionId AND Status ='Pending'];
        Map<Id,ProcessInstance> instancemap = new Map<Id,ProcessInstance>();
        for(ProcessInstance pi : prsInstance){
            instancemap.put(pi.Id,pi);
        }
        List<ProcessInstanceWorkitem> piwrkitem=[SELECT Id,Actor.Name,ProcessInstance.ProcessDefinition.DeveloperName,ProcessInstanceId from ProcessInstanceWorkitem Where ActorId = :userID ];//AND  ProcessInstanceId IN :prsInstance
        List<Id> oppIds = new List<Id>();
        for (ProcessInstanceWorkitem workid : piwrkitem) {
        if(instancemap.containsKey(workid.ProcessInstanceId)){
            oppIds.add(instancemap.get(workid.ProcessInstanceId).TargetObjectId);
        }
        }
        List<Opportunity> opportunities = [
            SELECT Id,name, Product_Name__r.Name, Account.Name, Compositions__c, Pack_Size__c, Plant__c, Firm_Quantity__c, LastModifiedDate, LastModifiedBy.Name,PPIC_Approval__c,Pricing_Approval__c,Approval_Status__c	
            FROM Opportunity 
            WHERE Id IN :oppIds
           // AND Approval_Status__c = 'Pending'
            //AND Approval_Status__c != 'Rejected'
        ];
        List<OpportunityWrapper> wrappers = new List<OpportunityWrapper>();
        for (Opportunity opp : opportunities) {
            wrappers.add(new OpportunityWrapper(opp));
        }
        system.debug('opportunities: ' +wrappers);
        jsonData = JSON.serialize(wrappers);
        return jsonData;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        return profileName != null ? profileName : '';
    }
    
    @AuraEnabled
    public static String startApprovalProcess(List<String> opportunityIds , String comments) {
        System.debug('opportunityIds22: ' + opportunityIds);
        Id pricingProfileId = [SELECT Id FROM Profile WHERE Name = 'Pricing Approval' LIMIT 1].Id;
        Id ppicProfileId = [SELECT Id FROM Profile WHERE Name = 'PPIC Approval' LIMIT 1].Id;
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id userProfileId = UserInfo.getProfileId();
        
        if (userProfileId == pricingProfileId || userProfileId == ppicProfileId || userProfileId == systemAdminProfileId) {
            List<Id> oppIds = new List<Id>();
            for (String oppId : opportunityIds) {
                oppIds.add(oppId);
            }
            
            System.debug('Opportunity IDs: ' + oppIds);
            
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id, ProcessInstanceId 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId IN :oppIds
            ];
            
            System.debug('Work Items: ' + workItems);
            
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            
            for (ProcessInstanceWorkitem workItem : workItems) {

                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                req.setComments(comments);
                requests.add(req);
                System.debug('workItem 76' +workItem );
                                System.debug('req 76' +req );

            }  
            
            
            if (!requests.isEmpty()) {
                Approval.ProcessResult[] processResults = Approval.process(requests);
                System.debug('Approval Process Results: ' + processResults);
                // Update Opportunity records with rejection reason
                List<Opportunity> opportunitiesToUpdate = [
                    SELECT Id, Comments__c, PPIC_Rejection_Date__c,Pricing_Rejection_Date__c,PPIC_Approval_Date__c,Pricing_Approval_Date__c // Update with your actual field API name
                    FROM Opportunity 
                    WHERE Id IN :oppIds
                ];
                
                for (Opportunity opp : opportunitiesToUpdate) {
                    opp.Comments__c = comments; 
                    if(userProfileId == ppicProfileId || userProfileId == systemAdminProfileId){
                        opp.Pricing_Approval_Date__c = System.Today();
                    }
                }
                
                update opportunitiesToUpdate;
                return 'Approval process started successfully';
            } else {
                return 'No opportunities found for approval';
            }
        } else {
            return 'User does not have the required permissions to start the approval process';
        }
    }
    
    @AuraEnabled
    public static String rejectOpportunities(List<String> opportunityIds, String rejectionReason) {
        Id pricingProfileId = [SELECT Id FROM Profile WHERE Name = 'Pricing Approval' LIMIT 1].Id;
        Id ppicProfileId = [SELECT Id FROM Profile WHERE Name = 'PPIC Approval' LIMIT 1].Id;
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id userProfileId = UserInfo.getProfileId();
        
        if (userProfileId == pricingProfileId || userProfileId == ppicProfileId || userProfileId == systemAdminProfileId) {
            List<Id> oppIds = new List<Id>();
            for (String oppId : opportunityIds) {
                oppIds.add(oppId);
            }
            
            System.debug('Opportunity IDs: ' + oppIds);
            
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id, ProcessInstanceId 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId IN :oppIds
            ];
            
            System.debug('Work Items: ' + workItems);
            
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Reject');
                req.setComments(rejectionReason); // Set the rejection reason in comments
                requests.add(req);
            }
            
            if (!requests.isEmpty()) {
                Approval.ProcessResult[] processResults = Approval.process(requests);
                System.debug('Rejection Process Results: ' + processResults);
                
                // Update Opportunity records with rejection reason
                List<Opportunity> opportunitiesToUpdate = [
                    SELECT Id, Comments__c, PPIC_Rejection_Date__c,Pricing_Rejection_Date__c // Update with your actual field API name
                    FROM Opportunity 
                    WHERE Id IN :oppIds
                ];
                
                for (Opportunity opp : opportunitiesToUpdate) {
                    opp.Comments__c = rejectionReason;
                    opp.Remarks__c = rejectionReason; 
                    if(userProfileId == ppicProfileId ||userProfileId == systemAdminProfileId){
                        opp.PPIC_Rejection_Date__c = System.Today();
                    }
                    if(userProfileId == pricingProfileId ||userProfileId == systemAdminProfileId){
                        opp.Pricing_Rejection_Date__c = System.Today();
                    }
                }
                
                update opportunitiesToUpdate; // Update Opportunity records
                
                return 'Rejection process started successfully';
            } else {
                return 'No opportunities found for rejection';
            }
        } else {
            return 'User does not have the required permissions to reject opportunities';
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