public class uploadFileController {
	@AuraEnabled
    public static void readCSVFile(Id idContentDocument,String partnerId){
        system.debug('idContentDocument----'+idContentDocument+'-----'+partnerId);
        ContentVersion objVersion = [SELECT Id, VersionData,Title FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
        if(objVersion.Title.containsIgnoreCase('unassign') ||  objVersion.Title.containsIgnoreCase('assign')){
            Database.executeBatch(new PartnerMembersAmendmentBatchClass(objVersion.VersionData,partnerId,objVersion.Title),2000);
        }else{
            Database.executeBatch(new UploadPMUBatch(objVersion.VersionData,partnerId),Integer.valueOf(System.Label.UploadPMUBatchSize));
        }
    }
}