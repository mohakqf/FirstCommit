public class OpportunityTriggerHandlerHelper {
    
    public static void createPreCase(List<Opportunity> newList){
        try{
            Id preCaseRecordtypeID = 
				Schema.SObjectType.Case__c.getRecordTypeInfosByName().get('Pre-Case').getRecordTypeId();
            List<Case__C> caseToInsert = new List<Case__C>();
           
            for (Opportunity opp : newList) {
                 system.debug('_________'+opp.Id);
                 system.debug('_________'+opp.RecordTypeId);
                system.debug('_________'+Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(opp.RecordTypeId).getName());
                if(opp.Product_Name__c != null){
                    Case__c cse = new Case__C();
                    cse.Account_Name__c = opp.AccountId;
                    cse.Product_Name__c = opp.Product_Name__c;
                    cse.Opportunity__c = opp.Id;
                    cse.RecordTypeId = preCaseRecordtypeID;
                    cse.Oppty_Record_Type__c = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(opp.RecordTypeId).getName();
                    caseToInsert.add(cse);
                }
            }
            insert caseToInsert;
            
            system.debug('____Case: '+caseToInsert);
            
            List<Opportunity> opptyListToUpdate = new List<Opportunity>();
            Map<String,Id> caseOptyMap = new Map<String, Id>();
            for(Case__C cRec : caseToInsert){
                caseOptyMap.put(cRec.Opportunity__c, cRec.Id);
            }
            
            for (Opportunity opp : newList) {
                if(caseOptyMap.containsKey(opp.id)){
                    Opportunity oppty = new Opportunity();
                	oppty.id = Opp.Id;
                    oppty.Case__c = caseOptyMap.get(oppty.id);
                    opptyListToUpdate.add(oppty);
                }  
            }
            update opptyListToUpdate;
        }
        catch(Exception e){
            system.debug('Exception while inserting Case: '+e);
        }
    }
    
}