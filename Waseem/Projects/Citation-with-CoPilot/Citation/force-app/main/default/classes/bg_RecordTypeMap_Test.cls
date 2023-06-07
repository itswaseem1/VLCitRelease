@isTest
public class bg_RecordTypeMap_Test {
    
    public static Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Account').getDescribe();
    
    @isTest static void testSuccessrecordtypefetch(){
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Schema.RecordTypeInfo recType = recordTypeInfo[0];
        Id RecordtypeId = recType.getRecordTypeId();
        String Name = recType.getName();
        Test.startTest();
        	bg_RecordTypeMap AccountRecordTypeMap = new bg_RecordTypeMap('Account');
        	id recId = AccountRecordTypeMap.getIdFromName(Name);
        	String recName = AccountRecordTypeMap.getNameFromID(RecordtypeId);
        Test.stopTest();
        System.assertEquals(RecordtypeId, recId);
        System.assertEquals(Name, recName);
    }
    
     @isTest static void testInvalidName(){
         String expMsg;
         String Name = 'sgdkasdagd';
        Test.startTest();
        	bg_RecordTypeMap AccountRecordTypeMap = new bg_RecordTypeMap('Account');
         try{
             id recId = AccountRecordTypeMap.getIdFromName(Name);
         } Catch(Exception e){
             expMsg = e.getMessage();
         }
        Test.stopTest();
         System.assertEquals(expMsg , 'Invalid Record Type - ' + name);

    }
    
    @isTest static void testInvalidId(){
         String expMsg;
        String recName = '';
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
       	Schema.RecordTypeInfo recType = recordTypeInfo[0];
        Id idval = recType.getRecordTypeId();
        Test.startTest();
        	bg_RecordTypeMap AccountRecordTypeMap = new bg_RecordTypeMap('Account');
         try{
            recName = AccountRecordTypeMap.getNameFromID(idval + 'x');
         } Catch(Exception e){
             expMsg = e.getMessage();
         }
        Test.stopTest();
         System.assert(String.isBlank(recName));

    }
}