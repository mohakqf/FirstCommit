trigger AccountTeam1 on Account (after insert, after update) {
    // Collect AccountTeamMember records to insert
    List<AccountTeamMember> accountTeamMembersToInsert = new List<AccountTeamMember>();
    
    // Map to store existing AccountTeamMembers by Account Id
    Map<Id, List<AccountTeamMember>> existingTeamMembersMap = new Map<Id, List<AccountTeamMember>>();
    
    // Set to hold Account Ids that need updates (for bulkification)
    Set<Id> accountIdsToUpdate = new Set<Id>();
    
    // Query existing AccountTeamMembers related to updated Accounts
    for (Account acc : [SELECT Id, (SELECT Id, UserId FROM AccountTeamMembers) FROM Account WHERE Id IN :Trigger.newMap.keySet()]) {
        existingTeamMembersMap.put(acc.Id, acc.AccountTeamMembers);
    }
    
    for (Account acc : Trigger.new) {
        // Initialize a list to store existing UserIds for comparison
        Set<Id> existingUserIds = new Set<Id>();
        
        if (existingTeamMembersMap.containsKey(acc.Id)) {
            for (AccountTeamMember atm : existingTeamMembersMap.get(acc.Id)) {
                existingUserIds.add(atm.UserId);
            }
        }
        
        // Check and handle BD_User_1__c
        if (acc.BD_User_1__c != null && !existingUserIds.contains(acc.BD_User_1__c)) {
            AccountTeamMember teamMember = new AccountTeamMember();
            teamMember.AccountId = acc.Id;
            teamMember.UserId = acc.BD_User_1__c;
            teamMember.TeamMemberRole = 'BD User 1'; // Adjust role as needed
            teamMember.AccountAccessLevel = 'Edit';
            accountTeamMembersToInsert.add(teamMember);
            accountIdsToUpdate.add(acc.Id);
            System.debug('Adding BD_User_1__c to AccountTeamMember: ' + teamMember);
        }
        
        // Check and handle BD_User_2__c
        if (acc.BD_User_2__c != null && !existingUserIds.contains(acc.BD_User_2__c)) {
            AccountTeamMember teamMember = new AccountTeamMember();
            teamMember.AccountId = acc.Id;
            teamMember.UserId = acc.BD_User_2__c;
            teamMember.TeamMemberRole = 'BD User 2'; // Adjust role as needed
            teamMember.AccountAccessLevel = 'Edit';
            accountTeamMembersToInsert.add(teamMember);
            accountIdsToUpdate.add(acc.Id);
            System.debug('Adding BD_User_2__c to AccountTeamMember: ' + teamMember);
        }
        
        // Check and handle BD_User_3__c
        if (acc.BD_User_3__c != null && !existingUserIds.contains(acc.BD_User_3__c)) {
            AccountTeamMember teamMember = new AccountTeamMember();
            teamMember.AccountId = acc.Id;
            teamMember.UserId = acc.BD_User_3__c;
            teamMember.TeamMemberRole = 'BD User 3'; // Adjust role as needed
            teamMember.AccountAccessLevel = 'Edit';
            accountTeamMembersToInsert.add(teamMember);
            accountIdsToUpdate.add(acc.Id);
            System.debug('Adding BD_User_3__c to AccountTeamMember: ' + teamMember);
        }
        
        // Check and handle BD_User_4__c
        if (acc.BD_User_4__c != null && !existingUserIds.contains(acc.BD_User_4__c)) {
            AccountTeamMember teamMember = new AccountTeamMember();
            teamMember.AccountId = acc.Id;
            teamMember.UserId = acc.BD_User_4__c;
            teamMember.TeamMemberRole = 'BD User 4'; // Adjust role as needed
            teamMember.AccountAccessLevel = 'Edit';
            accountTeamMembersToInsert.add(teamMember);
            accountIdsToUpdate.add(acc.Id);
            System.debug('Adding BD_User_4__c to AccountTeamMember: ' + teamMember);
        }
    }
    
    // Insert new AccountTeamMembers
    if (!accountTeamMembersToInsert.isEmpty()) {
        insert accountTeamMembersToInsert;
        System.debug('Inserted AccountTeamMembers: ' + accountTeamMembersToInsert);
    }

    // Delete old AccountTeamMembers
    List<AccountTeamMember> teamMembersToDelete = new List<AccountTeamMember>();
    for (Account acc : [SELECT Id, (SELECT Id, UserId FROM AccountTeamMembers) FROM Account WHERE Id IN :accountIdsToUpdate]) {
        for (AccountTeamMember atm : acc.AccountTeamMembers) {
            if ((Trigger.newMap.get(acc.Id).BD_User_1__c == null || !Trigger.newMap.get(acc.Id).BD_User_1__c.equals(atm.UserId)) &&
                (Trigger.newMap.get(acc.Id).BD_User_2__c == null || !Trigger.newMap.get(acc.Id).BD_User_2__c.equals(atm.UserId)) &&
                (Trigger.newMap.get(acc.Id).BD_User_3__c == null || !Trigger.newMap.get(acc.Id).BD_User_3__c.equals(atm.UserId)) &&
                (Trigger.newMap.get(acc.Id).BD_User_4__c == null || !Trigger.newMap.get(acc.Id).BD_User_4__c.equals(atm.UserId))) {
                teamMembersToDelete.add(atm);
                System.debug('Marking AccountTeamMember for deletion: ' + atm);
            }
        }
    }
    
    if (!teamMembersToDelete.isEmpty()) {
        delete teamMembersToDelete;
        System.debug('Deleted AccountTeamMembers: ' + teamMembersToDelete);
    }
}