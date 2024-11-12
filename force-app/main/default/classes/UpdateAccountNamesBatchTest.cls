@isTest
private class UpdateAccountNamesBatchTest {
    @isTest
    static void testBatchJob() {
        List<Account> testAccountsData = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            testAccountsData.add(new Account(Name = 'Test Account ' + i));
            System.debug('account list' + testAccountsData);
        }
        
        insert testAccountsData;

        Test.startTest();

        UpdateAccountNamesBatch batchJob = new UpdateAccountNamesBatch();
        Database.executeBatch(batchJob);

        List<Account> updatedAccounts = [SELECT Id, Name FROM Account];
        
        System.assertEquals(testAccountsData.size(), updatedAccounts.size());
        for (Integer i = 0; i < testAccountsData.size(); i++) {
            System.assertEquals(testAccountsData[i].Name, updatedAccounts[i].Name);
        }
    }
}