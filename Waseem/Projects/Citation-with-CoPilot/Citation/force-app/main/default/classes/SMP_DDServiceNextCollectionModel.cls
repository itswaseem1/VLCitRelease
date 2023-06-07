@JsonAccess(serializable='always' deserializable='always')
global with sharing class SMP_DDServiceNextCollectionModel
{
    @AuraEnabled public CollectionDateResult CollectionDateResult;
    @AuraEnabled global String Error;

    @JsonAccess(serializable='always' deserializable='always')
    global class CollectionDateResult
    {
        @AuraEnabled public String Error;
        @AuraEnabled public String CollectionDate;

        @AuraEnabled public String request_collectionday;
        @AuraEnabled public String request_collectionperiod;
        @AuraEnabled public String request_numberofdaystowaitfromnewinstruction;
        @AuraEnabled public String request_startdate;
    }

    global SMP_DDServiceNextCollectionModel(){
        CollectionDateResult = new CollectionDateResult();
    }

    global static SMP_DDServiceNextCollectionModel parse(String json)
    {
        return (SMP_DDServiceNextCollectionModel) System.JSON.deserialize(json, SMP_DDServiceNextCollectionModel.class);
    }
}