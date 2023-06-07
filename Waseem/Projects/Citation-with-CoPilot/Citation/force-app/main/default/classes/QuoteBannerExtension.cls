public with sharing class QuoteBannerExtension {

    private final Boolean hasInvalidProduct;

    public QuoteBannerExtension(ApexPages.StandardController stdController) {

        for(SBQQ__QuoteLine__c record: [select Id, Invalid_CPQ_Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: stdController.getId()]){

            if(record.Invalid_CPQ_Product__c){
                hasInvalidProduct = true;
                break;
            }

        }
    }

    public Boolean getHasInvalidProduct(){
        return hasInvalidProduct;
    }
}