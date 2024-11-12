@isTest
public class OpportunityController_Test {
    @testSetup
    public static void Testsetup(){
        
        Profile pdmin = [SELECT Id FROM Profile WHERE Name Like '%System Admin%'  LIMIT 1]; 
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pdmin.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='rmdm1azser3@testorg.com');
        insert u3;
        
        Account acc = new Account();
        acc.Name = 'test Account';
        acc.Segments__c = 'Hormone';
        acc.State_Province__c = 'UP';
        acc.Street__c = 'noida';
        acc.top_countries_of_business__c = 'India';
        insert acc;
        
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            Product2 prod = new Product2(
                Name = 'Test Product' + i,
                Plant__c = '9001',
                Type_of_Molecule__c = 'Regular',
                Dosage_Type__c = 'Tablets',
                Composition__c = 'test',
                CompositionCheck__c = true
                
            );
            products.add(prod);
        }
        insert products;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Product Requirement',
                AccountId = acc.Id,
                Firm_Quantity__c=23,
                Tentative_Quantity__c=23,
                Tentative_Transfer_price__c=23,
                Product_Name__c = products[i].Id,
                CloseDate = Date.today().addDays(30),
                Approval_Status__c = 'Pending',
                Email__c = 'shivam4@quadrafort.com',
                Country__c = 'India'
            );
            opportunities.add(opp);
        }
        insert opportunities;
        
    }
    @isTest
    public static void Test1(){
        User u3 = [Select Id from User where username='rmdm1azser3@testorg.com'];
        System.runAs(u3){
        List<Opportunity> opplist = OpportunityController.getOpportunities();
        OpportunityController.getUserProfileName();
        List<String> oppidlist = new List<String>();
        for(Opportunity opp : opplist){
            oppidlist.add(opp.id);
        }
        
        OpportunityController.startApprovalProcess(oppidlist,'Approved');
        OpportunityController.validateOpportunityUpdate(opplist);
        }}
    @isTest
    public static void Test2(){
        User u3 = [Select Id from User where username='rmdm1azser3@testorg.com'];
        System.runAs(u3){
        List<Opportunity> opplist = OpportunityController.getOpportunities();
        OpportunityController.getUserProfileName();
        List<String> oppidlist = new List<String>();
        for(Opportunity opp : opplist){
            oppidlist.add(opp.id);
        }
        OpportunityController.rejectOpportunities(oppidlist,'Rejected');
    	OpportunityController.validateOpportunityUpdate(opplist);
        }}
}