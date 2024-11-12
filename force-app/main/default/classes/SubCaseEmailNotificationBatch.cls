global class SubCaseEmailNotificationBatch implements Database.Batchable<SObject> {
    
    // 1. Query to get Sub_Case__c records created in the last 3 days
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue'];
        Set<Id> ownerIds = new Set<Id>();
        
        // Add Queue Ids to ownerIds set
        for (Group queue : queues) {
            ownerIds.add(queue.Id);
        }
        
        String query = 'SELECT Id, OwnerId, CreatedDate, Sub_Case_Type__c, Name, Account_Name__c FROM Sub_Case__c ' +
            'WHERE CreatedDate = LAST_N_DAYS:1 AND OwnerId In :ownerIds';
        return Database.getQueryLocator(query);
    }
    
    // 2. Process each batch of records
    global void execute(Database.BatchableContext bc, List<Sub_Case__c> scope) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Set<Id> ownerIds = new Set<Id>();
        
        // Collect all unique OwnerIds to query for managers
        for (Sub_Case__c subCase : scope) {
            ownerIds.add(subCase.OwnerId);
        }
        
        // Query the User object to get the Manager's email
        Map<Id, User> owners = new Map<Id, User>([SELECT Id, ManagerId, Manager.Email FROM User WHERE Id IN :ownerIds]);
        
        // Loop through each Sub_Case__c and prepare the email
        for (Sub_Case__c subCase : scope) {
            
            String headEmail;
            
            User owner = owners.get(subCase.OwnerId);
            if(subCase.Sub_Case_Type__c  == 'Physical Parameters' || subCase.Sub_Case_Type__c  == 'Packaging' ||subCase.Sub_Case_Type__c  == 'Change part' ||subCase.Sub_Case_Type__c  == 'API Vendor' ||
               subCase.Sub_Case_Type__c  == 'Trial batch and Stability' ||subCase.Sub_Case_Type__c  == 'Tech pack' ||subCase.Sub_Case_Type__c  == 'Samples')
            {
                headEmail = 'rishik@quadrafort.com';
            }
            else if(subCase.Sub_Case_Type__c  == 'DCGI Approval' || subCase.Sub_Case_Type__c  == 'LFDA Approval')
            {
                headEmail = 'rishik@quadrafort.com';
            }
            else if(subCase.Sub_Case_Type__c  == 'R&D/ DCGI/Commercial' || subCase.Sub_Case_Type__c  == 'Dossiers' || subCase.Sub_Case_Type__c  == 'COPP' || subCase.Sub_Case_Type__c  == 'DMF')
            {
                headEmail = 'rishik@quadrafort.com';
            }
            
            // Prepare the email to the manager
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { headEmail });
            email.setCCAddresses(new String[] { 'shivam@quadrafort.com' });
            email.setSubject('Sub Case Not moving forward from Last 3 Days');
            
            String htmlBody = '<html><body>' +
                '<p>Hi!</p>' +
                '<p>A new Sub Case <b>'+subCase.Name+'</b> was created on Account <b>'+subCase.Account_Name__c +'</b> recently and assigned to queue but is not moving ahead.</p>' +
                '<p>Best Regards,<br/>Synokem.</p>' +
                '</body></html>';
            email.setHtmlBody(htmlBody);
            
            email.setPlainTextBody('Hi, \nA new Sub Case '+subCase.Name+' was created on Account '+subCase.Account_Name__c +' recently and assigned to queue but is not moving ahead.');
            emailsToSend.add(email);
            
        }
        
        // Send all emails in a single call
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    // 3. Finish method (can be used to log or send notifications after batch completes)
    global void finish(Database.BatchableContext bc) {
        // Optionally, add logic to log the success or failure of the batch process
        System.debug('Batch Process completed successfully.');
    }
}