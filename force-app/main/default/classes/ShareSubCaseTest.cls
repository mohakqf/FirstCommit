@isTest
public class ShareSubCaseTest {
    @isTest
    static void testShareSubCaseAfterInsert() {
        // Create a test sub case
        Sub_Case__c subCase = new Sub_Case__c(
            Assigned_to__c = '0050T000004vYVnQAM', // Replace with a valid user ID
            OwnerId = '0050T000004vYVnQAM', // Replace with a valid user ID
            Case__c = 'a03Il000000xYWrIAM' // Replace with a valid case ID
        );
        
        // Insert the sub case
        insert subCase;
        
        // Verify that the sub case share was created
        List<Sub_Case__Share> subCaseShares = [SELECT Id FROM Sub_Case__Share WHERE ParentId = :subCase.Id];
        System.assertEquals(1, subCaseShares.size());
        
        // Verify that the case share was created
        List<Case__Share> caseShares = [SELECT Id FROM Case__Share WHERE ParentId = :subCase.Case__c];
        System.assertEquals(1, caseShares.size());
    }
    
    @isTest
    static void testShareSubCaseAfterUpdate() {
        // Create a test sub case
        Sub_Case__c subCase = new Sub_Case__c(
            Assigned_to__c = null,
            OwnerId = '0050T000004vYVnQAM', // Replace with a valid user ID
            Case__c = 'a03Il000000xYWrIAM' // Replace with a valid case ID
        );
        
        // Insert the sub case
        insert subCase;
        
        // Update the sub case with a new assigned to user
        subCase.Assigned_to__c = '0050T000004vYVnQAM'; // Replace with a valid user ID
        update subCase;
        
        // Verify that the sub case share was created
        List<Sub_Case__Share> subCaseShares = [SELECT Id FROM Sub_Case__Share WHERE ParentId = :subCase.Id];
        System.assertEquals(1, subCaseShares.size());
        
        // Verify that the case share was created
        List<Case__Share> caseShares = [SELECT Id FROM Case__Share WHERE ParentId = :subCase.Case__c];
        System.assertEquals(1, caseShares.size());
    }
    
    @isTest
    static void testShareSubCaseNoAssignedTo() {
        // Create a test sub case with no assigned to user
        Sub_Case__c subCase = new Sub_Case__c(
            Assigned_to__c = null,
            Case__c = 'a03Il000000xYWrIAM' // Replace with a valid case ID
        );
        
        // Insert the sub case
        insert subCase;
        
        // Verify that no shares were created
        List<Sub_Case__Share> subCaseShares = [SELECT Id FROM Sub_Case__Share WHERE ParentId = :subCase.Id];
        System.assertEquals(0, subCaseShares.size());
        
        List<Case__Share> caseShares = [SELECT Id FROM Case__Share WHERE ParentId = :subCase.Case__c];
        System.assertEquals(0, caseShares.size());
    }
}