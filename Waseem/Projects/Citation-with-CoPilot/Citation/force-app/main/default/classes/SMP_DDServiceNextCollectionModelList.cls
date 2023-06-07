@JsonAccess(serializable='always' deserializable='always')
global with sharing class SMP_DDServiceNextCollectionModelList {

    @AuraEnabled global List<CollectionDatesResult> CollectionDatesResult;
    @AuraEnabled global String Error;

    @JsonAccess(serializable='always' deserializable='always')
    global class CollectionDatesResult {
        @AuraEnabled global String Error;
        @AuraEnabled global String CollectionDate;

        @AuraEnabled global String request_collectionday;
        @AuraEnabled global String request_collectionperiod;
        @AuraEnabled global String request_numberofdaystowaitfromnewinstruction;
        @AuraEnabled global String request_startdate;
    }
    
    global static SMP_DDServiceNextCollectionModelList parse(String json) {
        return (SMP_DDServiceNextCollectionModelList) System.JSON.deserialize(json, SMP_DDServiceNextCollectionModelList.class);
    }
}