@isTest
public class ContractActivateJobTest
{
    @testSetup 
    private static void setup(){
      TestDataFactory.getStandardContracts(); 
    }
    
    @isTest
    private static void ActivateContractTest(){
        Contract cont = [SELECT id, status FROM contract][0];
        System.assertEquals('Draft', cont.Status);

        Test.startTest();
        String result = System.enqueueJob(new ContractActivateJob(cont.id));
        Test.stopTest();

        cont = [SELECT id, status FROM contract WHERE Id = :cont.Id][0];
        System.assertEquals('Active', cont.Status);
    }     
}