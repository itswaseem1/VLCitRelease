@istest
public class QmsReferralControllerTest {

    
    public static testMethod void testFecthProducts(){
        List<String> productlist = QmsReferralsController.fetchProducts();
        System.assertEquals(productlist.size()>0, true,'Records fetched');
    }  
    public static testMethod void testLead(){
     
        Account acc = new Account(Name='Test Acc');
        insert acc;
        Contact con = new Contact();
        con.AccountId=acc.id;
        con.FirstName='test';
        con.LastName='contact';
        con.Email='acb@def.com';
        con.Phone='123456789';
        insert con;
        List<String> productlist = new List<String>{'ISO 9001 Quality','ISO 14001 Environment'};
        string comment = 'test refer';
        QmsReferralsController.createLead(comment, acc.id, con.id, productlist);
        System.assertEquals([select id,LeadSource from Lead Where LeadSource='Ref_Employee_QMS'].size(),1,'success');
            
    }
}