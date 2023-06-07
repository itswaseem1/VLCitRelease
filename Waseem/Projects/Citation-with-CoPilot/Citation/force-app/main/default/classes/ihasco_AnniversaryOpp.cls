/*Schedulable Batch class to update opportunities */
public class ihasco_AnniversaryOpp implements Schedulable{
    public void execute(SchedulableContext ctx){
        List<Task> tsks = new List<Task>();
        //Map of old opps vs new opps
        Map<Opportunity,Opportunity> oldnew = new Map<Opportunity,Opportunity>();
        //List of new opps
        List<Opportunity> newopps =new List<Opportunity>();
        //List of new line items
        List<OpportunityLineItem> newoppproducts =new List<OpportunityLineItem>();
        //List of subscriptions to avoid in amendments
        List<Id> badsubs = new List<Id>();
        //List of subscriptions to include when creating line ites
        List<SBQQ__Subscription__c> goodsubs = new List<SBQQ__Subscription__c>();
        //Map of contract and its subscriptions
        Map<Contract,List<SBQQ__Subscription__c>> oldconssubs = new Map<Contract,List<SBQQ__Subscription__c>>();
        //Days before renewal
        Integer daysfromrenew = integer.valueof(System.Label.AnniversaryOpp_DaysFromRenew);
        //today
        Date todya = system.today();
        //90 days from today
        Date annivdate = system.today()+daysfromrenew;
        //day of the year 90 days from today
        Integer annivstartdate=annivdate.dayOfYear();
        //Date where renewals begin - with a margin of error
        Date renewalyr = todya.addYears(1);
        //iHasco record type
        Id taskrecord = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default iHASCO').getRecordTypeId();
        Id recordtypesid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Id Opprecrtype = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        //list of contracts that need an anniversary
        List<Contract> contractlist = [SELECT SBQQ__Opportunity__c,SBQQ__Opportunity__r.AccountId,Total_Contract_Value__c FROM Contract WHERE DAY_IN_YEAR(EndDate)=:annivstartdate AND RecordTypeId=:recordtypesid AND Enddate>=:renewalyr AND Status='Active'];
        //Map of opportunites that need an anniversary
        Map<Id,Opportunity> mapofops = new Map<Id,Opportunity>([SELECT Id, Name,AccountId,Contact__c,Parent_Opportunity__c,Account.iHASCO_Account_Manager__c FROM Opportunity WHERE Id IN (SELECT SBQQ__Opportunity__c FROM Contract WHERE DAY_IN_YEAR(EndDate)=:annivstartdate AND RecordTypeId=:recordtypesid AND Enddate>=:renewalyr AND Status='Active')]);
        //Map for contracts and new opportunities
        Map<Contract, Opportunity> connewopp = new Map<Contract, Opportunity>();
        //Map for contracts and old opportunities
        Map<Contract, Opportunity> newmapp = new Map<Contract, Opportunity>();
        
        For(Contract con2:contractlist){
            If(con2.SBQQ__Opportunity__c!=NULL){
                
            
            newmapp.put(con2,mapofops.get(con2.SBQQ__Opportunity__c));
                
         }   
        }
        //Filtering out the amended subscriptions for each contract
        If(contractlist.size()!=0){
            for(Contract con:contractlist){

                List<SBQQ__Subscription__c> oldsubs =[SELECT Id, Name,SBQQ__RevisedSubscription__c,SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__ListPrice__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:con.Id];
                
                For(SBQQ__Subscription__c sub:oldsubs){
                    If(sub.SBQQ__RevisedSubscription__c!=NULL){
                        badsubs.add(sub.SBQQ__RevisedSubscription__c);
                        
                    }
                    If(sub.SBQQ__Quantity__c<1){
                        badsubs.add(sub.Id);
                    }
                }
                For(SBQQ__Subscription__c sub2:oldsubs){
                    If(!badsubs.contains(sub2.Id)){
                        goodsubs.add(sub2);
                        
                    }
                }
                List<SBQQ__Subscription__c> goodsubs2 = new List<SBQQ__Subscription__c>(goodsubs);
                oldconssubs.put(con,goodsubs2);
                goodsubs.clear();
                

            }
        }
        //Creating the anniversary opportunity
        If(contractlist.size()!=0){
            for(Contract con:contractlist){
                
              Opportunity oldopp = newmapp.get(con);
                
                
                
                Opportunity clonedopp = oldopp.clone(false, false, false, false);
                
                clonedopp.OwnerId=oldopp.Account.iHASCO_Account_Manager__c;
                clonedopp.StageName='Genuine interest';
                clonedopp.AccountId=oldopp.AccountId;
                clonedopp.Contact__c=oldopp.Contact__c;
                clonedopp.Name=oldopp.Name+'-'+'Anniversary'+'-'+annivdate.format();
                clonedopp.Parent_Opportunity__c=oldopp.Id;
                clonedopp.CloseDate=annivdate;
                clonedopp.ContractId=con.Id;
                clonedopp.RecordTypeId=Opprecrtype;
                clonedopp.Type='Anniversary';
                clonedopp.ACV__c=con.Total_Contract_Value__c;
                 

                
                newopps.add(clonedopp);
                connewopp.put(con,clonedopp);
                
                
            }
        }
        
            try {
            
            insert connewopp.values();
            } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            }

        //Creating the new opp products
        system.debug('first'+oldconssubs.keyset());
        system.debug('second'+oldconssubs);
        For(Contract con3:oldconssubs.keyset()){
            Opportunity newoppd = connewopp.get(con3);
                                        Task tsk = new Task();
            tsk.RecordTypeId=taskrecord;
            tsk.Subject='New Anniversary Opportunity';
            tsk.WhatId=newoppd.Id;
            tsk.OwnerId=newoppd.Account.iHASCO_Account_Manager__c;
            tsk.Comment__c='Opportunity due for anniversary on the '+annivdate;
            tsk.ActivityDate=todya;
            tsks.add(tsk);
            

            For(SBQQ__Subscription__c oldsubs:oldconssubs.get(con3)){
                    
                    OpportunityLineItem newlineitem = new OpportunityLineItem();
                    newlineitem.OpportunityId = newoppd.Id;
                    newlineitem.Product2Id = oldsubs.SBQQ__Product__c;
                    newlineitem.Quantity = oldsubs.SBQQ__Quantity__c;
                    newlineitem.TotalPrice = oldsubs.SBQQ__ListPrice__c;
                    newlineitem.PricebookEntryId=oldsubs.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c;
                    
                    newoppproducts.add(newlineitem);
                
                system.debug('lineitems'+newoppproducts);
            }
        }
        
       try {
           
            insert newoppproducts;
           insert tsks;
       } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
       }
            
        }}