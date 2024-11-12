trigger CaseTrigger on Case__c (before insert, before update, after insert, after update) {
    List<Sub_Case__c> subCasesToInsert = new List<Sub_Case__c>();

    List<Group> queueList = [select Id, Name from Group where Type = 'Queue'];
    Map<String, ID> queueMap = new Map<String,Id>();
    for(Group queueRec : queueList){
        queueMap.put(queueRec.Name, queueRec.Id);
    }
    // Handling Insert Context
    if (Trigger.isInsert && trigger.isbefore ) {
        
        
        
        for (Case__c caseRecord : Trigger.new) {
            subCasesToInsert.addAll(CaseTriggerHelper.checkAndCreateSubCases(caseRecord, null, queueMap));
        }
        
        // Filter cases that have the Initimating_Sub_Function__c field filled
        List<Case__c> casesWithInitimatingSubFunction = new List<Case__c>();
        for (Case__c caseRecord : Trigger.new) {
            if (caseRecord.Initimating_Sub_Function__c != null && caseRecord.Initimating_Sub_Function__c != '') {
                casesWithInitimatingSubFunction.add(caseRecord);
            }
        }
        if (!casesWithInitimatingSubFunction.isEmpty()) {
            CaseTriggerHelper.createSubcasesOnCase(casesWithInitimatingSubFunction);
        }
        
        for (Case__c caseRecord : Trigger.new) {
            subCasesToInsert.addAll(CaseTriggerHelper.checkAndCreateSubCases(caseRecord, null, queueMap));
        }
    }
    
    // Handling after Insert Context
    if (Trigger.isInsert && Trigger.isAfter ) {
        
    }

    // Handling Update Context
    if (Trigger.isUpdate && Trigger.isBefore ) {
        for (Case__c caseRecord : Trigger.new) {
            Case__c oldCaseRecord = Trigger.oldMap.get(caseRecord.Id);
            subCasesToInsert.addAll(CaseTriggerHelper.checkAndCreateSubCases(caseRecord, oldCaseRecord, queueMap));
        }
        
        // Only create subcases if the Initimating_Sub_Function__c field has changed
         CaseTriggerHelper.preventSubFunctionRemoval(Trigger.new, Trigger.oldMap);
        Map<Id, Case__c> oldCaseMap = Trigger.oldMap;
        List<Case__c> casesWithNewValues = CaseTriggerHelper.getCasesWithNewValues(Trigger.new, oldCaseMap);
        if (!casesWithNewValues.isEmpty()) {
            CaseTriggerHelper.createSubcasesOnCase(casesWithNewValues);
        }
    }

    if (!subCasesToInsert.isEmpty()) {
        insert subCasesToInsert;
    }
}