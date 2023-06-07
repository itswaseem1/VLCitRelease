@isTest
public class ActivateContractController_Test {

    @testSetup static void setup(){
      TestDataFactory.getStandardContracts(); 
    }
    
    static testMethod void ActivateContractTest(){
        List<Contract> conList = [select id, status from contract];
        Test.startTest();
        String result = ActivateContractController.Activate(conList[0].id);
        Test.stopTest();
        System.assertEquals('success', result);
    } 
    
    static testMethod void ActivateContractInsufficientAccess(){
        List<Contract> conList = [select id, status from contract];
        List<Profile> p = [select id , name from profile where PermissionsActivateContract = false LIMIT 1]; 
        if(p != NULL && p.size() != 0){
            user u = TestDatafactory.createUser_Generic((String)p[0].name, '', true);
            System.runas(u){
                Test.startTest(); 
                String result = ActivateContractController.Activate(conList[0].id);
                Test.stopTest();
                System.assertEquals('Permission Denied', result);
            }
        }
    } 
    
}