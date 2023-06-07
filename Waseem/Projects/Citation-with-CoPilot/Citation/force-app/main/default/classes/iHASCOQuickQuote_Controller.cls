public with Sharing class iHASCOQuickQuote_Controller {
    @auraEnabled(cacheable=true)
    public static List<SBQQ__ProductOption__c> getProductList(String licenseModel){
        CPQQuoteService.CPQQuoteServiceSelector selector=new CPQQuoteService.CPQQuoteServiceSelector();
        CPQQuoteService service= new CPQQuoteService(selector); 
        return  service.getProductList(licenseModel).values();
    }
    @auraEnabled 
    public static String createQuickQuote(String licenseModel, String productId, String term, String noOfUnits, String oppoId)
    {
        CPQQuoteService.CPQQuoteServiceSelector selector=new CPQQuoteService.CPQQuoteServiceSelector();
        CPQQuoteService service= new CPQQuoteService(selector);
        String quoteId= service.createQuickQuote(licenseModel, productId, term, noOfUnits, oppoId);
        String qLE_URL=URL.getOrgDomainUrl().toExternalForm()+'/apex/sbqq__sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId;
        return qLE_URL;
    }
}