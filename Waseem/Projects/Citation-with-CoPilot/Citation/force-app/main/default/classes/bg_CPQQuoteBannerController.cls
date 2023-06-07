public with sharing class bg_CPQQuoteBannerController {

    /*
	private ApexPages.StandardController standardController; 

    public bg_CPQQuoteBannerController(ApexPages.StandardController stdController) {
        standardController = stdController;
    }

    public void stampUserDetails() 
    {
       
        SBQQ__Quote__c currentQuote = (SBQQ__Quote__c)standardController.getRecord();
        currentQuote = [select id,Most_Recent_Viewer__c,SBQQ__Status__c from SBQQ__Quote__c where id = :currentQuote.id ] ;

        if(currentQuote != null && currentQuote.Most_Recent_Viewer__c != UserInfo.getUserId() && !Approval.isLocked(currentQuote.Id))
        {
            currentQuote.Most_Recent_Viewer__c = UserInfo.getUserId();
            
            update currentQuote;
        }
    }
*/
}