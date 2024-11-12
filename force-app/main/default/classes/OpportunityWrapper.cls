/**
* @File Name : OpportunityWrapper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : October 17, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 17, 2024 |   | Initial Version
**/
public class OpportunityWrapper {
    public Id id;
    public String opportunityName;
    public String productName;
    public String customerName;
    public String packSize;
    public String compositions;
    public String plant;
    public String firmQuantity;
    public DateTime lastModifiedDate;
    public string approval;
   

    public OpportunityWrapper(Opportunity opp) {
        this.id = opp.Id;
        this.approval= opp.Approval_Status__c;	
        this.opportunityName = opp.Name;
        this.productName = opp.Product_Name__r != null ? opp.Product_Name__r.Name : 'N/A';
        this.customerName = opp.Account != null ? opp.Account.Name : 'N/A';
        this.packSize = opp.Pack_Size__c != null ? String.valueOf(opp.Pack_Size__c) : 'N/A'; // Convert Decimal to String
        this.compositions = opp.Compositions__c != null ? String.valueOf(opp.Compositions__c) : 'N/A'; // Convert Decimal to String
        this.plant = opp.Plant__c != null ? String.valueOf(opp.Plant__c) : 'N/A'; // Convert Decimal to String
        this.firmQuantity = opp.Firm_Quantity__c != null ? String.valueOf(opp.Firm_Quantity__c) : 'N/A'; // Convert Decimal to String
        this.lastModifiedDate = opp.LastModifiedDate;
    }
}