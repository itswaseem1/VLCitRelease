/*********************************** 
   QuoteLineItemHandler
 * This handler works on Sum of Children Price Per Billing field population
 * CreatedBy : Sai Karthik Anupoju
 * Date      : 21th August 2019
************************************/

public class QuoteLineItemHandler {
  
  //This method is to set the start date to quote line in before context 
  public List<SBQQ__QuoteLine__c> appendStartDate(List<SBQQ__QuoteLine__c> qtLInes){
      for(SBQQ__QuoteLine__c cpQL: qtLInes){
          if(cpQL.SBQQ__StartDate__c == null && cpQL.SBQQ__EffectiveStartDate__c != null){
              cpQL.SBQQ__StartDate__c = cpQL.SBQQ__EffectiveStartDate__c;
          }
      
      }
      
      return qtLInes;
  }

  public void nonPricingCalculator(List<SBQQ__QuoteLine__c> quoteLineTriggerList){
    
    System.debug('Inside non Pricing Calculator:::'+quoteLineTriggerList.size());
    List<SBQQ__QuoteLine__c> quoteLineUpList = new List<SBQQ__QuoteLine__c>();
    Set<SBQQ__QuoteLine__c> quoteLineList = new Set<SBQQ__QuoteLine__c>();
    Map<Id,Decimal> childQuoteMap = new Map<Id,Decimal>();
    
    try{
      for(SBQQ__QuoteLine__c ql:quoteLineTriggerList){
        if(ql.SBQQ__RequiredBy__c==null){
            quoteLineList.add(ql);
        }
      }
      System.debug('quoteLineList:::'+quoteLineList);
     
      if(!quoteLineList.isEmpty()){
        for(AggregateResult rs:[SELECT SBQQ__RequiredBy__c,SUM(Price_per_Billing_Frequency__c) sumTotal FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c!=NULL  and SBQQ__RequiredBy__c IN:quoteLineList GROUP BY SBQQ__RequiredBy__c ]){
            System.debug('Inside the FOR loop');
            childQuoteMap.put((Id)rs.get('SBQQ__RequiredBy__c'),(Decimal)rs.get('sumTotal'));
        }
      }
      System.debug('childQuoteMap:::'+childQuoteMap);

      if(!childQuoteMap.isEmpty()){
        for(SBQQ__QuoteLine__c ql:quoteLineList){
          if(childQuoteMap.containsKey(ql.Id)){
            ql.Sum_of_Children_Price_Per_Billing__c = (Decimal)childQuoteMap.get(ql.Id);
            System.debug('ql.Sum_of_Children_Price_Per_Billing__c:::'+ql.Sum_of_Children_Price_Per_Billing__c);
            quoteLineUpList.add(ql);
          }
        }
      }
    }

    catch(Exception ex){
      System.debug('Error Message:::'+ex.getMessage());
    }
  }
    // As part of SDT-4989 story we have displayed productsheets in quote temaplte based on quote line items   
 public void updateCoreProduct(List<SBQQ__QuoteLine__c> newQuoteLine){     
        Set<Id> quoteId = new Set<Id>();
        List<SBQQ__Quote__c> coreProductList = new List<SBQQ__Quote__c>();
     	Set<String> productCodeSet = new Set<String>();
        for(SBQQ__QuoteLine__c qtl:newQuoteLine ){
            System.debug('Core product:' + qtl.SBQQ__ProductCode__c);           
                quoteId.add(qtl.SBQQ__Quote__c);            
        }
         for(SBQQ__Quote__c quoteVal:[SELECT Id,Personal_Part_HR__c,Personal_Part_HS__c,Workplace_Expt_HR__c,Workplace_Expt_HS__c,Virtual_Assist_HR__c,Virtual_Assist_HS__c,HowToHub_HR__c,HowToHub_HS__c,(Select Id, SBQQ__Group__r.SBQQ__Optional__c, SBQQ__ProductCode__c from SBQQ__LineItems__r  WHERE SBQQ__Group__r.SBQQ__Optional__c = FALSE) FROM SBQQ__Quote__C WHERE Id IN:quoteId]){
             productCodeSet.clear();
             for(SBQQ__QuoteLine__c qtl:quoteVal.SBQQ__LineItems__r ){            
                 productCodeSet.add(qtl.SBQQ__ProductCode__c);
             }
             quoteVal.Personal_Part_HR__c =  productCodeSet.contains('HR-PersPrt') ? true: false; 
             quoteVal.Personal_Part_HS__c =  productCodeSet.contains('H&S-PersPrt') ? true: false;
             quoteVal.Workplace_Expt_HR__c= productCodeSet.contains('HR-CSE') ? true: false;                
             quoteVal.Workplace_Expt_HS__c= productCodeSet.contains('HS-CSE') ? true: false;
             quoteVal.Virtual_Assist_HR__c= productCodeSet.contains('HR-Virtass') ? true: false;
             quoteVal.Virtual_Assist_HS__c= productCodeSet.contains('H&S-Virtass') ? true: false;
             quoteVal.HowToHub_HR__c=  productCodeSet.contains('HR-HtoH') ? true: false;
             quoteVal.HowToHub_HS__c= productCodeSet.contains('H&S-HtoH') ? true: false;               
             coreProductList.add(quoteVal);
         }
        if(!coreProductList.isempty()){
            database.update(coreProductList,false);
        }
      
    }
    public void qmsupdateQuoteDocSwitches(List<SBQQ__QuoteLine__c> newQuoteLine){     
        Set<Id> quoteId = new Set<Id>();
        List<SBQQ__Quote__c> coreProductList = new List<SBQQ__Quote__c>();
        Set<String> productCodeSet = new Set<String>();
        Set<String> serviceSet = new Set<String>();
        Set<String> businessContinuityCodes = new Set<String>();
        businessContinuityCodes.add('Business Continuity-CPQ-J');
        businessContinuityCodes.add('BCR-CPQ-J');
        businessContinuityCodes.add('Business Continuity-A');
        
        Set<String> ConnectCodes = new Set<String>();
        ConnectCodes.add('QMS Connect Combined-CPQ-D');
        ConnectCodes.add('QMSCECC-CPQ');
        ConnectCodes.add('CECT-AL');
        ConnectCodes.add('CECT-AL2');
        ConnectCodes.add('CECT-AL3');
        ConnectCodes.add('CECT-CPQ-D');
        ConnectCodes.add('CECT-OB3');
        ConnectCodes.add('QMS-Connect-LO -CPQ-D');
        ConnectCodes.add('QMSL1ISO');
        ConnectCodes.add('QMSL2ISO');
        ConnectCodes.add('QMSL3ISO');
        ConnectCodes.add('QMS-Connect-LMSC-CPQ-D');
        ConnectCodes.add('QMSCC-CPQ-D');
        ConnectCodes.add('QMS Connect Transition-CPQ-D');
        
        for(SBQQ__QuoteLine__c qtl:newQuoteLine ){          
            quoteId.add(qtl.SBQQ__Quote__c);            
        }
        
        for(SBQQ__Quote__c quoteVal:[SELECT Id, QMS_ISO45003_Doc__c, QMS_businessContinuity_doc__c, QMS_Connect_doc__c, QMS_ISO9001_14001_45001_training__c, QMS_ISO27001_training__c, QMS_Audit_training__c, QMS_eLearning_doc__c, QMS_Compliance_process__c, QMS_Core_process__c, QMS_Premium_process__c, QMS_UKAS_process__c, QMS_Consultancy_process__c,(Select Id,SBQQ__ProductCode__c, Service__c,Custom_Discount_Amount__c,Custom_Discount_Percentage__c  from SBQQ__LineItems__r) FROM SBQQ__Quote__C WHERE Id IN:quoteId]){
            productCodeSet.clear();
            serviceSet.clear();
            quoteVal.QMS_businessContinuity_doc__c = false;
            quoteVal.QMS_Connect_doc__c = false;
            quoteVal.QMS_ISO9001_14001_45001_training__c = false;
            quoteVal.QMS_ISO27001_training__c = false;
            quoteVal.QMS_Audit_training__c = false;
            quoteval.QMS_ISO45003_Doc__c = false;
            
            
            for(SBQQ__QuoteLine__c qtl:quoteVal.SBQQ__LineItems__r ){            
                productCodeSet.add(qtl.SBQQ__ProductCode__c);
                serviceSet.add(qtl.Service__c);
                if(businessContinuityCodes.contains(qtl.SBQQ__ProductCode__c)){
                    quoteVal.QMS_businessContinuity_doc__c = true;
                }
                if(ConnectCodes.contains(qtl.SBQQ__ProductCode__c)){
                    quoteVal.QMS_Connect_doc__c = true;
                }       
            }
            quoteVal.QMS_eLearning_doc__c =  productCodeSet.contains('eLearning-CPQ-E') ? true: false; 
            quoteval.QMS_ISO45003_Doc__c = productCodeSet.contains('ISO 45003-CPQ-A') ? true: false;
            quoteVal.QMS_Compliance_process__c = serviceSet.contains('Compliance') ? true : false;
            quoteVal.QMS_Core_process__c = serviceSet.contains('Core') ? true : false;
            quoteVal.QMS_Premium_process__c = serviceSet.contains('Premium') ? true : false;
            quoteVal.QMS_UKAS_process__c = serviceSet.contains('UKAS') ? true : false;
            quoteVal.QMS_Consultancy_process__c = serviceSet.contains('Consultancy') ? true : false;
            if(serviceSet.contains('Internal Audit Training')){
                if(productCodeSet.contains('IMS ISO 9001 / ISO 14001 / ISO 45001-CPQ-F')){
                    quoteVal.QMS_ISO9001_14001_45001_training__c = true;
                } else if (productCodeSet.contains('ISO 27001-CPQ-B')) {
                    quoteVal.QMS_ISO27001_training__c = true;
                } else {
                    quoteVal.QMS_Audit_training__c = true;
                }
            }
            coreProductList.add(quoteVal);
        }
        if(!coreProductList.isempty()){
            database.update(coreProductList,false);
        }
        
    }
}