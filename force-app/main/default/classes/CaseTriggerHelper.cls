public class CaseTriggerHelper {
    
    public static List<Sub_Case__c> checkAndCreateSubCases(Case__c caseRecord, Case__c oldCaseRecord, Map<String, ID> queueMap) {
        
        List<Sub_Case__c> subCases = new List<Sub_Case__c>();

        // Check each field for 'Not Available' value
        if (caseRecord.DMF__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.DMF__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord,'DMF | Not Available', 'DMF', queueMap));
        }
        if (caseRecord.Dossiers__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Dossiers__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'Dossiers | Not Available', 'Dossiers', queueMap));
        }
        if (caseRecord.Packaging_Primary_Secondary_details__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Packaging_Primary_Secondary_details__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'Packaging | Not Available', 'Packaging', queueMap));
        }
        if (caseRecord.Physical_Parameters__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Physical_Parameters__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'Physical Parameters | Not Available', 'Physical Parameters', queueMap));
        }
        if (caseRecord.Tech_Pack_MOA_COA_Stability_Backup_PV__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Tech_Pack_MOA_COA_Stability_Backup_PV__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'Tech Pack | Not Available', 'Tech pack', queueMap));
        }
        if (caseRecord.DCGI_Approval__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.DCGI_Approval__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'DCGI | Not Available', 'DCGI Approval', queueMap));
        }
        if (caseRecord.LFDA_Approval__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.LFDA_Approval__c != 'Not Available')) {
            subCases.add(createSubCase(caseRecord, 'LFDA Approval | Not Available', 'LFDA Approval', queueMap));
        }
        if (caseRecord.Change_Part__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Change_Part__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'Change Part | Not Available', 'Change part', queueMap ));
		}
		if (caseRecord.API_Vendor__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.API_Vendor__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'API Vendor | Not Available', 'API Vendor', queueMap));
		}
		if (caseRecord.Trial_Batch_and_Stability__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Trial_Batch_and_Stability__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'Trial Batch and Stability | Not Available', 'Trial batch and Stability', queueMap));
		}
		if (caseRecord.Samples__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.Samples__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'Sample | Not Available', 'Samples', queueMap));
		}
		if (caseRecord.RnD_DGCI_Comm__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.RnD_DGCI_Comm__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'RnD DGCI Comm | Not Available', 'R&D/ DCGI/Commercial', queueMap));
		}
		if (caseRecord.COPP__c == 'Not Available' && (oldCaseRecord == null || oldCaseRecord.COPP__c != 'Not Available')) {
  subCases.add(createSubCase(caseRecord, 'COPP | Not Available', 'COPP', queueMap));
		}
        return subCases;
    }
    

    public static void createSubcasesOnCase(List<Case__c> caseList) {
        List<Sub_Case__c> subcasesToInsert = new List<Sub_Case__c>();
        //Map<Id, Id> caseToOwnerMap = new Map<Id, Id>();

        // Collect all picklist values to query profiles and users
        Set<String> allPicklistValues = new Set<String>();
        for (Case__c caseRecord : caseList) {
            if (caseRecord.Initimating_Sub_Function__c != null) {
                allPicklistValues.addAll(caseRecord.Initimating_Sub_Function__c.split(';'));
            }
        }

        // Query users for the profiles based on picklist values
        Map<String, Id> userIdByPicklistValue = new Map<String, Id>();
        for (User user : [
            SELECT Id, Profile.Name 
            FROM User 
            WHERE Profile.Name IN :allPicklistValues AND IsActive = true
        ]) {
            userIdByPicklistValue.put(user.Profile.Name, user.Id);
        }
      System.debug('user'+userIdByPicklistValue);
        for (Case__c caseRecord : caseList) {
            // Get the selected values from the multi-select picklist
            List<String> selectedValues = caseRecord.Initimating_Sub_Function__c != null ? caseRecord.Initimating_Sub_Function__c.split(';') : new List<String>();

            // Create subcases for each selected value
            for (String value : selectedValues) {
                Id ownerId = userIdByPicklistValue.get(value);
                if (ownerId != null) {
                    Sub_Case__c subcase = new Sub_Case__c();
                    subcase.Case__c = caseRecord.Id;
                    subcase.OwnerId = ownerId;
                    // Set other fields on the subcase as needed
                    subcasesToInsert.add(subcase);
                    
                }
            }
        }

        if (!subcasesToInsert.isEmpty()) {
            insert subcasesToInsert;
        }
    }
 public static void preventSubFunctionRemoval(List<Case__c> newCases, Map<Id, Case__c> oldCaseMap) {
    for (Case__c newCase : newCases) {
        // Get the old version of the Case record
        Case__c oldCase = oldCaseMap.get(newCase.Id);
        
        // Split the multi-select picklist values into sets for easy comparison
        Set<String> newSubFunctions = new Set<String>();
        Set<String> oldSubFunctions = new Set<String>();

        if (newCase.Initimating_Sub_Function__c != null) {
            newSubFunctions.addAll(newCase.Initimating_Sub_Function__c.split(';'));
        }
        if (oldCase.Initimating_Sub_Function__c != null) {
            oldSubFunctions.addAll(oldCase.Initimating_Sub_Function__c.split(';'));
        }
        
        System.debug('New Subfunction values: ' + newSubFunctions);
        System.debug('Old Subfunction values: ' + oldSubFunctions);

        // Check if any values have been removed
        if (!newSubFunctions.containsAll(oldSubFunctions)) {
            // If values are removed, throw an error
            newCase.addError('You cannot remove existing sub-function values. You can only add new values.');
        }
    }
}

  public static List<Case__c> getCasesWithNewValues(List<Case__c> newCases, Map<Id, Case__c> oldCasesMap) {
        List<Case__c> casesWithNewValues = new List<Case__c>();

        for (Case__c newCase : newCases) {
            Case__c oldCase = oldCasesMap.get(newCase.Id);
            if (oldCase != null) {
                // Split the multi-select picklist values into sets for comparison
                Set<String> oldValues = new Set<String>(oldCase.Initimating_Sub_Function__c != null ? oldCase.Initimating_Sub_Function__c.split(';') : new List<String>());
                Set<String> newValues = new Set<String>(newCase.Initimating_Sub_Function__c != null ? newCase.Initimating_Sub_Function__c.split(';') : new List<String>());

                // Determine newly added values
                Set<String> addedValues = new Set<String>(newValues);
                addedValues.removeAll(oldValues);

                if (!addedValues.isEmpty()) {
                    // Create a copy of the case to use for creating subcases
                    Case__c caseWithNewValues = new Case__c(
                        Id = newCase.Id,
                        Initimating_Sub_Function__c = String.join(new List<String>(addedValues), ';')
                    );
                    casesWithNewValues.add(caseWithNewValues);
                }
            }
        }
        return casesWithNewValues;
    }

    private static Sub_Case__c createSubCase(Case__c caseRecord, String caseName, String caseType, Map<String, ID> queueMap) {
        system.debug('****** '+caseRecord.Oppty_Record_Type__c );
        system.debug('******__________ '+(caseRecord.Oppty_Record_Type__c == 'CDMO' ? queueMap.get('CQA') : queueMap.get('DRA')) );
        return new Sub_Case__c(
            Case__c = caseRecord.Id,
            Name = caseName,
            Sub_Case_Type__c = caseType,
            ownerId = caseRecord.Oppty_Record_Type__c == 'CDMO' ? queueMap.get('CQA') : queueMap.get('DRA')
        );
    }
}