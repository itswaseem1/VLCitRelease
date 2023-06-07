@isTest
public class SubscriptionHelperTest {
    
    static testMethod void TestsetAccount() {
        List<SBQQ__Subscription__c> listSub=new List<SBQQ__Subscription__c>();
        
        Account acc = new Account();
        acc.Name = 'testName';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;     
        acc.Sites__c = 1;        
        insert acc;
        
        Contact con=new Contact();
        con.LastName='test';
        con.Email='ramadevithota@citation.co.uk';
        con.AccountId=acc.Id;
        insert con;
        
        Contract cont=new Contract();
        cont.Name='name';
        cont.AccountId=acc.id;
        cont.StartDate=system.today();
        cont.ContractTerm=12;
        cont.CustomerSignedId=con.Id;
        cont.FOC_Period_Mths__c=12;
        cont.FOC_Period_Mths_End__c=12;
        insert cont;
        
        Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
        EmployementLawPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        EmployementLawPRoduct.ProductCode = 'HR-HtoH';
        insert EmployementLawPRoduct; 
        
        SBQQ__Subscription__c subs1 = new SBQQ__Subscription__c(SBQQ__Contract__c=cont.id, sbqq__Product__c=EmployementLawPRoduct.id,sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Monthly',Subscription_Term_m__c=12) ;
        insert subs1;
        
        for(SBQQ__Subscription__c sub:[Select Id,sbqq__quantity__c FROM SBQQ__Subscription__c WHERE Id =:subs1.id  ]){
            sub.sbqq__quantity__c=2;
            listSub.add(sub);      
        }
        
        test.startTest();
        update listSub;
        test.stopTest();        
    }
}