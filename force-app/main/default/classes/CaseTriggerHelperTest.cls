@isTest
public class CaseTriggerHelperTest {
    @isTest
	static void testCheckAndCreateSubCases() {
    // Create a test case record
    Case__c caseRecord = new Case__c(
        DMF__c = 'Not Available',
        Dossiers__c = 'Not Available',
        Packaging_Primary_Secondary_details__c = 'Not Available',
        Physical_Parameters__c = 'Not Available',
        Tech_Pack_MOA_COA_Stability_Backup_PV__c = 'Not Available',
        DCGI_Approval__c = 'Not Available',
		LFDA_Approval__c = 'Not Available',
		Change_Part__c = 'Not Available',
		API_Vendor__c = 'Not Available',
		Trial_Batch_and_Stability__c = 'Not Available',
		Samples__c = 'Not Available',
		RnD_DGCI_Comm__c = 'Not Available',
		COPP__c = 'Not Available'
    );

    // Test insert
    List<Sub_Case__c> subCases = CaseTriggerHelper.checkAndCreateSubCases(caseRecord, null);
    System.assertEquals(13, subCases.size());

    // Test update
    Case__c oldCaseRecord = new Case__c(
        DMF__c = 'Available',
        Dossiers__c = 'Available',
        Packaging_Primary_Secondary_details__c = 'Available',
        Physical_Parameters__c = 'Available',
        Tech_Pack_MOA_COA_Stability_Backup_PV__c = 'Available',
        DCGI_Approval__c = 'Available',
        LFDA_Approval__c = 'Available',
		Change_Part__c = 'Not Available',
		API_Vendor__c = 'Not Available',
		Trial_Batch_and_Stability__c = 'Not Available',
		Samples__c = 'Not Available',
		RnD_DGCI_Comm__c = 'Not Available',
		COPP__c = 'Not Available'
    );

    subCases = CaseTriggerHelper.checkAndCreateSubCases(caseRecord, oldCaseRecord);
    System.assertEquals(13, subCases.size());
}

	//for Code Coverage of Trigger
  @isTest
  static void testUpdateWithNotAvailableValues() {
    // Create a Case record
    Case__c oldCase = new Case__c(DMF__c = 'Available');
    insert oldCase;

    // Update the Case record with a field set to 'Not Available'
    oldCase.DMF__c = 'Not Available';
    update oldCase;

    // Assert that the subCase was created
    List<Sub_Case__c> subCases = [SELECT Id FROM Sub_Case__c WHERE Case__c = :oldCase.Id];
    System.assertEquals(1, subCases.size(), 'SubCase should be created for updated Not Available DMF');
  }

}