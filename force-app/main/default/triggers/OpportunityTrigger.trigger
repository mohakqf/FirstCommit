trigger OpportunityTrigger on Opportunity(before update, after update, after insert) {
    if (Trigger.isUpdate) {
        System.debug('Trigger is in update context');
        OpportunityTriggerHandler.validateOpportunityUpdate(Trigger.new);
    }
  /**  if (Trigger.isBefore) {
        System.debug('Trigger is in before update context');
        OpportunityApprovalHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
    }

    if (Trigger.isAfter) {
        System.debug('Trigger is in after update context');
        OpportunityApprovalHandler.afterUpdate(Trigger.oldMap, Trigger.new);
    } **/
    
    if(Trigger.isAfter && Trigger.isInsert){
        //OpportunityTriggerHandler.afterInsert(Trigger.oldMap, Trigger.new);
    }
}