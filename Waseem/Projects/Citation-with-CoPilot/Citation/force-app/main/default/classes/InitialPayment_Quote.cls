public class InitialPayment_Quote{
	public static Boolean isCarePoliciesDeleted=false;
  public void autoPopulateQuoteLine(List<SBQQ__QuoteLine__c> newQuoteLine,boolean fromq,map<id,SBQQ__QuoteLine__c> oldMapQuoteLine,boolean insORUpdate){
      List<SBQQ__QuoteLine__c> noid = new List<SBQQ__QuoteLine__c>();
      boolean go = true;
      if(insORUpdate){
        if(AvoidRecursion.isFirstRun() || Test.isRunningTest()){
            system.debug('Executed/Not');
            Set<Id> quoteId = new Set<Id>();
            Set<Id> quoteLineId = new Set<Id>();
            Set<SBQQ__QuoteLine__c> setquoteLine = new Set<SBQQ__QuoteLine__c>();
            Set<SBQQ__Quote__c> finalQuoteSet = new Set<SBQQ__Quote__c>();
            Set<Date> allDates1 = new Set<Date>(); 
            List<Date> allDates = new List<Date>();
            List<Date> freemonthDate = new List<Date>();
            List<Date> sortedDate = new List<Date>();
            List<SBQQ__QuoteLine__c> quoteLineVal = newQuoteLine;
            List<SBQQ__QuoteLine__c> fnQTL = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__Quote__c> finalQuote = new List<SBQQ__Quote__c>();
            Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();
            Map<Id,SBQQ__Quote__c> mapQuotes = new Map<Id,SBQQ__Quote__c>();      
            Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
            Map<id,SBQQ__QuoteLine__c> opName = new Map<id,SBQQ__QuoteLine__c>();
            set<id> ProdId = new set<id>();
            map<id,SBQQ__QuoteLine__c> mapProdQuoteLine = new map<id,SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c qtl:newQuoteLine ){
                system.debug('20 qtl'+qtl);
                quoteId.add(qtl.SBQQ__Quote__c);
                quoteLineId.add(qtl.Id);
                //setquoteLine.add(qtl);
            }
            List<SBQQ__QuoteLine__c> quoteLine3 = [SELECT id,SBQQ__StartDate__c,SBQQ__Product__c,SBQQ__Product__r.FOC_Months_Eligible__c,SBQQ__Quantity__c,SBQQ__ProductCode__c,Billing_Frequency__c,SBQQ__BillingFrequency__c,FOC_Period__c,SBQQ__Quote__c,SBQQ__Group__c,Billing_Start_Date__c FROM SBQQ__QuoteLine__c WHERE Id IN:quoteLineId];
            List<SBQQ__QuoteLine__c> quoteLine2 = [SELECT id,SBQQ__StartDate__c,SBQQ__Product__c,SBQQ__Product__r.FOC_Months_Eligible__c,SBQQ__Quantity__c,SBQQ__ProductCode__c,Billing_Frequency__c,SBQQ__BillingFrequency__c,FOC_Period__c,SBQQ__Quote__c,SBQQ__Group__c,Billing_Start_Date__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteId];
            for(SBQQ__QuoteLine__c qtlf:quoteLine2){
                setquoteLine.add(qtlf);
            }
            for(SBQQ__QuoteLine__c qtlf:quoteLine3){
                setquoteLine.add(qtlf);
            }
            
            for(SBQQ__QuoteLine__c ql: setquoteLine){
                system.debug('after query results expected 3'+ql);
                if(ql.SBQQ__ProductCode__c == 'Free-Month'){
                    opName.put(ql.SBQQ__Group__c,ql);
                }
                if(ql.SBQQ__ProductCode__c == 'CB1' || ql.SBQQ__ProductCode__c == 'HS-Compliance' || ql.SBQQ__ProductCode__c == 'PEL'){
                            system.debug('+++CB1'+ql);
                            ProdId.add(ql.SBQQ__Product__c);
                        	mapProdQuoteLine.put(ql.SBQQ__Product__c,ql);
                            system.debug('ProdId+MapProdIdQuoteLine'+ProdId+mapProdQuoteLine);
                }
            }
            list<SBQQ__ProductOption__c> productOptionList = [select SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,id from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c In: ProdId];
            map<id,SBQQ__ProductOption__c> mapPrdOption = new map<id,SBQQ__ProductOption__c>();
            for(SBQQ__ProductOption__c SPO:productOptionList ){
            	  mapPrdOption.put(SPO.SBQQ__OptionalSKU__c,SPO);
            }
            
            // Quote map will holds the information of the CPQ quote id and record.
            for(SBQQ__Quote__c quoteVal:[SELECT SBQQ__StartDate__c,Preferred_Payment_Date__c,Initial_Payment_Date__c,FOC_Months__c FROM SBQQ__Quote__C WHERE Id IN:quoteId]){
                quoteMap.put(quoteVal.id,quoteVal);
            }
            
            // Below Logic is when we have Products 
            for(SBQQ__QuoteLine__c ql:setquoteLine){
                system.debug('expected to');
                 Date viaCal;
                 Date assignDate;
                // Below Logic is for other than Free-Month Product code
                ql.Service_Start_Date__c = quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c;
                ql.SBQQ__StartDate__c = quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c;
                if(quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c !=null && quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c >0 && ql.SBQQ__Product__r.FOC_Months_Eligible__c){
                    ql.FOC_Months__c=quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c;
                    ql.FOC_Period__c='Start';
                }else{
                   ql.FOC_Months__c=0;
                   ql.FOC_Period__c='Start';  
                }
                    if(!(ql.SBQQ__ProductCode__c == 'Free-Month')){
                        System.debug('No Free month');
                        if((quoteMap.containsKey(ql.SBQQ__Quote__C)) ? quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c != null : false){
                            if(!opName.isEmpty() && opName.containsKey(ql.SBQQ__Group__c) && (mapPrdOption.containsKey(ql.SBQQ__Product__c) || mapProdQuoteLine.containsKey(ql.SBQQ__Product__c))){
                                Date i = conditionCheckviaCal(ql.FOC_Months__c,quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c,ql.Billing_Frequency__c,opName.get(ql.SBQQ__Group__c).SBQQ__Quantity__c,opName.get(ql.SBQQ__Group__c).FOC_Period__c);
                                if(i != null){
                                    allDates.add(i);
                                    system.debug('allDatesnotfreebutsamegroup+'+allDates+'ivalue'+i+ql);
                                }
                            }
                        else if((quoteMap.containsKey(ql.SBQQ__Quote__C) && (!(opName.containsKey(ql.SBQQ__Group__c)) || !mapPrdOption.containsKey(ql.SBQQ__Product__c)))){
                            Date i = conditionCheck(ql.FOC_Months__c,quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c,ql.SBQQ__BillingFrequency__c,ql.FOC_Period__c);
                            if(i != null){
                               allDates.add(i);
                                system.debug('allDatesnotfreebutnotsamegroup+'+allDates+'i value');
                             }
                         }

                         system.debug('quote Intialpayment when non freemonth'+quoteMap.get(ql.SBQQ__Quote__C).Initial_Payment_Date__c);
                         ql.Billing_Start_Date__c = quoteMap.get(ql.SBQQ__Quote__C).Initial_Payment_Date__c;
                            
                     }      
                 }

            if(ql.SBQQ__ProductCode__c == 'Free-Month'){ 
                System.debug('Free month');
                    if(quoteMap.containsKey(ql.SBQQ__Quote__C) ? quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c != null : false){
                        viaCal = conditionCheckviaCal(ql.FOC_Months__c,quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c,ql.Billing_Frequency__c,ql.SBQQ__Quantity__c,ql.FOC_Period__c);
                        allDates.add(viaCal); 
                        system.debug('viacal+++'+viaCal+'alldatest++'+allDates);  
                    }   
                    //if(quoteMap.containsKey(ql.SBQQ__Quote__C) ? quoteMap.get(ql.SBQQ__Quote__C).Initial_Payment_Date__c != null : false){
                    if(quoteMap.containsKey(ql.SBQQ__Quote__C)){
                        system.debug('ql startdateviaCal'+viaCal);
                        ql.Billing_Start_Date__c = viaCal;
                        opName.put(ql.SBQQ__Group__c,ql);
                        assignDate = viaCal;
                    }
                }
                allDates.sort();
                if(!allDates.isEmpty() && quoteMap.containsKey(ql.SBQQ__Quote__C)){
                    SBQQ__Quote__c tempQuote = new SBQQ__Quote__c();
                    tempQuote = quoteMap.get(ql.SBQQ__Quote__C);
                    tempQuote.Initial_Payment_Date__c = allDates.get(0);
                    mapQuotes.put(tempQuote.id,tempQuote);
                }
            }
            
            
            //The below logic is used to update the quote with the least date as a Intial payment date
            if(!mapQuotes.isempty()){   
                quoteMap.clear();
                finalQuote.clear();
                list<SBQQ__Quote__c> fn = new list<SBQQ__Quote__c>();
                for(SBQQ__Quote__c sbq: mapQuotes.Values()){
                   fn.add(sbq); 
                }
               finalQuote.addall(fn);
               update fn;
               quoteMap = new Map<Id,SBQQ__Quote__c>(finalQuote);
            }
            
            //The below logic helps to update the quote lines with the correct startdate for free-month related production option.
            for(SBQQ__QuoteLine__c fnql:setquoteLine){
                system.debug('fnql+++1'+fnql);
                if(quoteMap.containsKey(fnql.SBQQ__Quote__C) && (opName.containsKey(fnql.SBQQ__Group__c)) && (mapPrdOption.containsKey(fnql.SBQQ__Product__c) || mapProdQuoteLine.containsKey(fnql.SBQQ__Product__c))){
                        system.debug('opname start date'+opName.get(fnql.SBQQ__Group__c).SBQQ__StartDate__c);
                   
                    fnql.Billing_Start_Date__c = opName.get(fnql.SBQQ__Group__c).Billing_Start_Date__c;
                    fnql.FOC_Period__c = opName.get(fnql.SBQQ__Group__c).FOC_Period__c;
                    fnql.FOC_Quantity__c = opName.get(fnql.SBQQ__Group__c).SBQQ__Quantity__c;
                    fnQTL.add(fnql);
                }
                
                else if(quoteMap.containsKey(fnql.SBQQ__Quote__C) && fnql.SBQQ__ProductCode__c !='Free-Month'){     
                    
                   // fnql.Billing_Start_Date__c = quoteMap.get(fnql.SBQQ__Quote__C).Initial_Payment_Date__c;
                    if(quoteMap.get(fnql.SBQQ__Quote__C).FOC_Months__c !=null && quoteMap.get(fnql.SBQQ__Quote__C).FOC_Months__c >0 && fnql.SBQQ__Product__r.FOC_Months_Eligible__c){
                        fnql.FOC_Period__c='Start';
                        fnql.Billing_Start_Date__c = conditionCheck(quoteMap.get(fnql.SBQQ__Quote__C).FOC_Months__c,quoteMap.get(fnql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(fnql.SBQQ__Quote__C).SBQQ__StartDate__c,fnql.SBQQ__BillingFrequency__c,fnql.FOC_Period__c);    
                    }else{
                       fnql.Billing_Start_Date__c = quoteMap.get(fnql.SBQQ__Quote__C).Initial_Payment_Date__c; 
                    }
                    //fnql.SBQQ__StartDate__c = allDates.get(0);
                    system.debug('when product code not free month'+quoteMap.get(fnql.SBQQ__Quote__C).Initial_Payment_Date__c);
                    fnQTL.add(fnql);
                }
            }
            
            if(!fnQTL.isempty() && true){
                system.debug('fnQTL ready to update'+fnQTL);
                update fnQTL;
            }
            system.debug('alldates+++'+allDates);
            for(SBQQ__Quote__c ql:quoteMap.values()){
                System.debug('ql++++++' + ql);
            }
        }    
      }
    	
    }
    
    // Below Loigc is when Quote creation via Pricing Calucator Initial Payment Date
    public Date conditionCheckviaCal(Decimal focMonth,String pickValue, Date dateValue, String billFrequency, Decimal freeMonQuantity, String focPeriod){
       System.debug('conditionCheckviaCal');
        Integer focMonths=Integer.valueOf(focMonth);
        Integer preferredDate = Integer.valueOf(pickValue);
        Integer startDate     = dateValue.day();
        Integer startMonth    = dateValue.month();
        Integer startYear     = dateValue.year();
        Integer freeQuan      = freeMonQuantity.intValue();
        Date initialPayment;
        
        if(focMonths != null && focMonths > 0 && focPeriod == 'Start'){
            initialPayment = Date.newInstance(startYear, startMonth, preferredDate);
              if(startDate < preferredDate){
                initialPayment = initialPayment.addMonths(focMonths); 
            }else{
                initialPayment = initialPayment.addMonths(focMonths+1);  
            }  
        }else if(freeQuan != null && focPeriod == 'Start'){
            initialPayment = Date.newInstance(startYear, startMonth, preferredDate);
            if(startDate < preferredDate){
            	initialPayment = initialPayment.addMonths(freeQuan);    
            }
            else {
                initialPayment = initialPayment.addMonths(freeQuan+1);
            }
        }
        if(focPeriod == 'End'){
            if(startDate < preferredDate ){
                initialPayment = Date.newInstance(startYear, startMonth, preferredDate);
            }else{
                initialPayment = Date.newInstance(startYear, startMonth+1, preferredDate);
            }
        }
        return initialPayment;
    }
    
    // Below Logic is when Normal Quote Creation Initial Payment Date
    public Date conditionCheck(Decimal focMonth,String pickValue, Date dateValue, String billFrequency,String focPeriod){
        System.debug('conditionCheck');
        Integer focMonths=Integer.valueOf(focMonth);
        Integer preferredDate = Integer.valueOf(pickValue);
        Integer startDate     = dateValue.day();
        Integer startMonth    = dateValue.month();
        Integer startYear     = dateValue.year();
        Date initialPayment;
        if(focMonths != null && focMonths > 0 && focPeriod == 'Start'){
            initialPayment = Date.newInstance(startYear, startMonth, preferredDate);
            if(startDate < preferredDate){
                initialPayment = initialPayment.addMonths(focMonths); 
            }else{
                initialPayment = initialPayment.addMonths(focMonths+1);  
            }  
        }else if(startDate < preferredDate ){           
            initialPayment = Date.newInstance(startYear, startMonth, preferredDate);
        }else{            
            initialPayment = Date.newInstance(startYear, startMonth+1, preferredDate);   
        }
        return initialPayment;
    }
    
    public void populateServiceBillingStartDatesForChildQuoteLines(List<SBQQ__QuoteLine__c> newQuoteLine){
        List<SBQQ__QuoteLine__c> childquoteLines=new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteIdSet = new Set<Id>();
        for(SBQQ__QuoteLine__c inql: newQuoteLine){
            if(inql.SBQQ__RequiredBy__c!=null){
                quoteIdSet.add(inql.SBQQ__Quote__c);
                childquoteLines.add(inql);
            }
        }
        system.debug('childquoteLines----'+childquoteLines);
        if(!childquoteLines.isEmpty()){
            Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();
            // Quote map will holds the information of the CPQ quote id and record.
            for(SBQQ__Quote__c quoteVal:[SELECT SBQQ__StartDate__c,Preferred_Payment_Date__c,Initial_Payment_Date__c,FOC_Months__c FROM SBQQ__Quote__C WHERE Id IN:quoteIdSet]){
                quoteMap.put(quoteVal.id,quoteVal);
            }
            // Below Logic is when we have Products 
            for(SBQQ__QuoteLine__c ql:childquoteLines){
                // Below Logic is for other than Free-Month Product code
                ql.Service_Start_Date__c = quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c;
                ql.SBQQ__StartDate__c = quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c;
                ql.FOC_Period__c='Start';
                if(quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c !=null && quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c >0 && ql.FOC_Months_Eligible__c){
                    ql.FOC_Months__c=quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c;
                    if(quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c!=null){
                      ql.Billing_Start_Date__c = conditionCheck(quoteMap.get(ql.SBQQ__Quote__C).FOC_Months__c,quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c,ql.SBQQ__BillingFrequency__c,ql.FOC_Period__c);
                    }
                }else{
                    ql.FOC_Months__c=0;
                    if(quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c!=null){
                      ql.Billing_Start_Date__c = conditionCheck(0,quoteMap.get(ql.SBQQ__Quote__C).Preferred_Payment_Date__c,quoteMap.get(ql.SBQQ__Quote__C).SBQQ__StartDate__c,ql.SBQQ__BillingFrequency__c,ql.FOC_Period__c);
                    }
                }
            }
        }
    }
    
  public void populateCarePoliciesChildCount(List<SBQQ__QuoteLine__c> quoteLineRecordsforProcessing,String Operation){
        set<Id> parentQuoteLineId=new set<Id>();
        set<Id> updatedParentQuoteLineId=new set<Id>();
        List<SBQQ__QuoteLine__c> listofQuoteLinestoUpdate=new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c objQuoteLine:quoteLineRecordsforProcessing){
            if(objQuoteLine.SBQQ__RequiredBy__c!=null && objQuoteLine.SBQQ__ProductCode__c != null && objQuoteLine.SBQQ__ProductCode__c.Startswith('CARE-POL-') && Operation=='Delete'){
                parentQuoteLineId.add(objQuoteLine.SBQQ__RequiredBy__c);
            }
            else if(objQuoteLine.SBQQ__RequiredBy__c==null && objQuoteLine.SBQQ__ProductCode__c != null && objQuoteLine.SBQQ__ProductCode__c=='CARE-POLICIES' && (Operation=='Update' || Operation=='Insert')){
                updatedParentQuoteLineId.add(objQuoteLine.Id);
             }
        }
        if( Operation=='Update'){
            isCarePoliciesDeleted=false;
        }
        if(!updatedParentQuoteLineId.isEmpty()){
            List<SBQQ__QuoteLine__c> quoteLineRecords=[select Id,SBQQ__RequiredBy__c,SBQQ__ProductCode__c,SBQQ__ListPrice__c,Count_of_LDSL__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c IN :updatedParentQuoteLineId];
            Set<Id> ParentandHasLDSLChildSet=new Set<Id>();
            Map<Id,Integer> ParentwithChildCountMap=new Map<Id,Integer>();
            for(SBQQ__QuoteLine__c objQuoteLine:quoteLineRecords){
                if(objQuoteLine.SBQQ__ProductCode__c=='CARE-POL-LDSL-ENGLAND'){
                    ParentandHasLDSLChildSet.add(objQuoteLine.SBQQ__RequiredBy__c);
                }
                if(ParentwithChildCountMap.containsKey(objQuoteLine.SBQQ__RequiredBy__c)){
                    ParentwithChildCountMap.put(objQuoteLine.SBQQ__RequiredBy__c, ParentwithChildCountMap.get(objQuoteLine.SBQQ__RequiredBy__c)+1);
                }
                else{
                  ParentwithChildCountMap.put(objQuoteLine.SBQQ__RequiredBy__c,1);
                }
            }
            for(SBQQ__QuoteLine__c objQuoteLine:quoteLineRecordsforProcessing){
                if(ParentwithChildCountMap.containsKey(objQuoteLine.Id)){
                    objQuoteLine.Count_of_children__c=ParentwithChildCountMap.get(objQuoteLine.Id);
                    if(ParentandHasLDSLChildSet.contains(objQuoteLine.Id)){
                        objQuoteLine.Count_of_LDSL__c=1;
                        if(objQuoteLine.SBQQ__BillingFrequency__c=='Monthly'){
                            objQuoteLine.SBQQ__ListPrice__c=25+(20*ParentwithChildCountMap.get(objQuoteLine.Id))+5;
                            //objQuoteLine.Initial_Payment__c=25+(20*ParentwithChildCountMap.get(objQuoteLine.Id))+5;
                        }
                        else if(objQuoteLine.SBQQ__BillingFrequency__c=='Annual'){
                            objQuoteLine.SBQQ__ListPrice__c=(25+(20*ParentwithChildCountMap.get(objQuoteLine.Id)))*12+60;
                            //objQuoteLine.Initial_Payment__c=(25+(20*ParentwithChildCountMap.get(objQuoteLine.Id)))*12+60;
                        }
                    }
                    else{
                        if(objQuoteLine.SBQQ__BillingFrequency__c=='Monthly'){
                            objQuoteLine.SBQQ__ListPrice__c=25+(20*ParentwithChildCountMap.get(objQuoteLine.Id));
                            //objQuoteLine.Initial_Payment__c=25+(20*ParentwithChildCountMap.get(objQuoteLine.Id));
                        }
                        else if(objQuoteLine.SBQQ__BillingFrequency__c=='Annual'){
                            objQuoteLine.SBQQ__ListPrice__c=(25+(20*ParentwithChildCountMap.get(objQuoteLine.Id)))*12;
                            //objQuoteLine.Initial_Payment__c=(25+(20*ParentwithChildCountMap.get(objQuoteLine.Id)))*12;
                        }
                    }
                }
            }
        }
        if(!parentQuoteLineId.isEmpty()){
            for(SBQQ__QuoteLine__c objQuoteLine:[Select Id,Count_of_children__c,(select Id From SBQQ__Quote_Lines__r) From SBQQ__QuoteLine__c where Id IN:parentQuoteLineId]){
                objQuoteLine.Count_of_children__c=objQuoteLine.SBQQ__Quote_Lines__r.size();
                listofQuoteLinestoUpdate.add(objQuoteLine);
            }
            if(!listofQuoteLinestoUpdate.isempty()){
                isCarePoliciesDeleted=true;
                Database.update(listofQuoteLinestoUpdate,false);
            }
        }
    }
}