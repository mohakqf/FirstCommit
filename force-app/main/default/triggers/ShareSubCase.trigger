trigger ShareSubCase on Sub_Case__c (after insert, after update) {
/*
    List<Sub_Case__Share> shares = new List<Sub_Case__Share>();
    List<Case__Share> case_shares = new List<Case__Share>();
    for (Sub_Case__c subCase : Trigger.new) {
        if (subCase.Assigned_to__c != null) {
            Sub_Case__Share share = new Sub_Case__Share();
            share.ParentId = subCase.Id;
            share.UserOrGroupId = subCase.Assigned_to__c;
            share.AccessLevel = 'Edit';
            share.RowCause = Schema.Sub_Case__Share.RowCause.Manual;
            shares.add(share);
        }
        if (subCase.Case__c != null){
            Case__Share share1 = new Case__Share();
            share1.ParentId = subCase.Case__c;
            share1.UserOrGroupId = subCase.Assigned_to__c;
            share1.AccessLevel = 'Read';
            share1.RowCause = Schema.Sub_Case__Share.RowCause.Manual;
            case_shares.add(share1);            
            }
    }
//
    for (Sub_Case__c subCase1 : Trigger.new) {
        if (subCase1.OwnerId != null) {
            Sub_Case__Share share2 = new Sub_Case__Share();
            share2.ParentId = subCase1.Id;
            share2.UserOrGroupId = subCase1.OwnerId;
            share2.AccessLevel = 'Edit';
            share2.RowCause = Schema.Sub_Case__Share.RowCause.Manual;
            shares.add(share2);
        }
        if (subCase1.Case__c != null){
            Case__Share share3 = new Case__Share();
            share3.ParentId = subCase1.Case__c;
            share3.UserOrGroupId = subCase1.OwnerId;
            share3.AccessLevel = 'Read';
            share3.RowCause = Schema.Sub_Case__Share.RowCause.Manual;
            case_shares.add(share3);            
            }
    }
//
    if (!shares.isEmpty()) {
        Database.SaveResult[] results = Database.insert(shares, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                // Handle any errors during the sharing process
                System.debug('Error sharing Sub Case: ' + result.getErrors()[0].getMessage());
            }
        }
    }
        if (!case_shares.isEmpty()) {
        Database.SaveResult[] results = Database.insert(case_shares, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                // Handle any errors during the sharing process
                System.debug('Error sharing Case: ' + result.getErrors()[0].getMessage());
            }
        }
   }*/ 
}