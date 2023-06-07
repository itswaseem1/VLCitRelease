@istest
public class SearchController_Test {
@isTest
    static void testmethodBDC(){
        Lead l=new Lead();
        l.LastName = 'TestNameBDC';
        l.Company ='ihasco BDC';
        insert l;
        list<string> fields=new list<string>{'LastName'};
        SearchController.search('Lead',fields,'test');
        system.assertEquals('ihasco BDC', l.Company);
    }
}