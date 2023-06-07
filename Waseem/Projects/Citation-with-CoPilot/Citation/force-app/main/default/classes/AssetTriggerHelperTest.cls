@isTest
public class AssetTriggerHelperTest {
    @testSetup static void setup(){
        Account acc = new Account(Name = 'TestAccount',AnnualRevenue = 100000,FT_Employees__c = 6,PT_Employees__c = 1,
                                  Sites__c = 1);
        insert acc;
        Contact cnt = new Contact(LastName='TestContact',AccountId =acc.id);
        insert cnt;
        Product2 prod = new Product2(Name = 'BS 15713 Product',Business_Type__c='QMS');
        insert prod;
      	ffbc__SoftDate__c softDate = TestHarness.createSoftDate(true);
      	fferpcore__Company__c billingCompany = TestHarness.createBillingCompany(false);
      	billingCompany.Name = 'QMS International Limited';
      	insert billingCompany;
        ffbc__Contract__c billingContract = TestHarness.createBillingContract(false,acc,billingCompany,null);
		billingContract.Contract_Type__c = 'New';
      	insert billingContract;
        ffbc__ContractLineItem__c billingContractLine = TestHarness.createBillingContractLine(false,prod,softDate,billingContract);
      	billingContractLine.Service_Start_Date__c = date.today();
      	billingContractLine.Service_End_Date__c = date.today().AddMonths(64);
        insert billingContractLine;
        SBQQ__Quote__c sbqut = new SBQQ__Quote__c(SBQQ__Primary__c=true,SBQQ__PrimaryContact__c=cnt.Id,SBQQ__StartDate__c=System.today(),
                                                 SBQQ__Status__c='Approved',Initial_Payment__c=1000,Initial_Payment_Date__c=System.today());
        insert sbqut;
        SBQQ__QuoteLine__c sbqutline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=sbqut.Id,SBQQ__Quantity__c=1,Certification__c='BS 15713 : 2009',
                                                             Service_Start_Date__c=System.today(),Billing_Start_Date__c=System.today(),SBQQ__Product__c=prod.Id,
                                                             SBQQ__EndDate__c=system.today()+90,SBQQ__StartDate__c=system.today());
        insert sbqutline;
        Pricebook2 pb = new Pricebook2(Name='Test PB',IsActive=true);
        insert pb;
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Quantity__c=1,SBQQ__Account__c=acc.Id,
                                                             SBQQ__QuoteLine__c=sbqutline.Id,SBQQ__Product__c=prod.Id);
        insert sub;
        billingContractLine.Subscription__c = sub.Id;
        update billingContractLine;
        Asset asst = new Asset(Name= 'Test Asset',Accountid = acc.id,Contactid = cnt.id,Product2Id =prod.id,Business_Area__c='QMS',
                              Billing_Contract__c=billingContract.Id,Billing_Contract_Line_Item__c=billingContractLine.Id);
		insert asst;
        Asset asst1 = new Asset(Name= 'Test Asset1',Accountid = acc.id,Contactid = cnt.id,Product2Id =prod.id,Business_Area__c='QMS',
                              Billing_Contract__c=billingContract.Id,Billing_Contract_Line_Item__c=billingContractLine.Id);
		insert asst1;
    }
    
    @isTest
    public static void checkCertificate(){
        system.assertEquals('In-Progress',[Select Id,Status__c from Certificate__c Limit 1]?.Status__c, 'Certificate Created');
    }

}