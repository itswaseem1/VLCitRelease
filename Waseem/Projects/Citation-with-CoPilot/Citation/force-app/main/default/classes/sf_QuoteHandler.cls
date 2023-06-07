public class sf_QuoteHandler{

    //The below method is used to populate/change the startd date on quote
    public void callQTLMethodForSTdate(List<SBQQ__Quote__c> newQuoteList, Map<Id,SBQQ__Quote__c> oldMapQuote){
        Set<Id> quotesForStart = new Set<Id>();
        Set<Id> emptyDateId = new Set<Id>();
        for(SBQQ__Quote__c quoteSB:newQuoteList){
            if(!oldMapQuote.isEmpty() && !newQuoteList.isEmpty()){
                if(oldmapQuote.get(quoteSB.id).SBQQ__StartDate__c != quoteSB.SBQQ__StartDate__c || oldmapQuote.get(quoteSB.id).Preferred_Payment_Date__c != quoteSB.Preferred_Payment_Date__c || oldmapQuote.get(quoteSB.id).FOC_Months__c != quoteSB.FOC_Months__c){
                   system.debug('quoteSB Value'+quoteSB);
                    quotesForStart.add(quoteSB.id);
               }
            }
        }
        if(!quotesForStart.isEmpty()){
            List<SBQQ__QuoteLine__c> sql1 = [SELECT SBQQ__StartDate__c,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Group__c,SBQQ__ProductCode__c,Billing_Frequency__c,SBQQ__BillingFrequency__c,FOC_Period__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c In:quotesForStart];
            System.debug('sql1'+sql1);
            if(!sql1.isEmpty()){
                InitialPayment_Quote inCon = new InitialPayment_Quote();
                inCon.autoPopulateQuoteLine(sql1,true,null,true);
            }
        }
    }
}