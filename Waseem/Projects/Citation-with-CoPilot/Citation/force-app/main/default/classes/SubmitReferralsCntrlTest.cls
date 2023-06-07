@isTest
public class SubmitReferralsCntrlTest {
    public static testMethod void testFecthProducts(){
        List<Product2> prods = new List<Product2>{new Product2(Name = 'Referral Product 1', Family = 'H&S', Referral_Product__c=true),
            new Product2(Name = 'Referral Product 2', Family = 'Training', Referral_Product__c=true),
            new Product2(Name = 'Referral Product 3', Family = 'Training', Referral_Product__c=true)};
        insert prods;
        Map<String, List<Product2>> prodFamily = SubmitReferralsCntrl.fetchProducts();
        System.assertEquals(prodFamily.size(), 2,'Records fetched');
    }  
    public static testMethod void testOpp(){
        Product2 prod = new Product2(Name = 'Referral Product 5', Family = 'H&S', Referral_Product__c=true);
        insert prod;
        Account acc = new Account(Name='Test Acc');
        insert acc;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Referrals Pricebook', isActive=true);
        insert customPB;
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        try {
            SubmitReferralsCntrl.createOpportunity(new Opportunity(Pricebook2Id = customPB.Id,AccountId=acc.Id),new List<Id>{prod.Id},new List<String>{prod.Name});
        } catch (AuraHandledException e) {
            System.debug('err msg'+e.getMessage());
            System.assert(e.getMessage().contains('Script'),'Exception occured');
        }
        
    } 
    @isTest
    public static void testContact(){
        Account acc = new Account(Name='Test Acc');
        insert acc;
        Contact con = new Contact(LastName = 'Joe Test', accountId = acc.id);
        insert con;
        List<Contact> contactList = SubmitReferralsCntrl.fetchContacts(acc.Id);
        SYstem.assertEquals('Joe Test', contactList[0].Name, 'Incorrect contact');
        Contact cont = SubmitReferralsCntrl.fetchContact(con.Id);
        System.assertEquals('Joe Test', cont.Name, 'Incorrect Name');
    }
}