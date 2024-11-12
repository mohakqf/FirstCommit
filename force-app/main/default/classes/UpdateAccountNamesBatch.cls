global class UpdateAccountNamesBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : scope) {
            acc.Name = acc.Name;
            accountsToUpdate.add(acc);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}