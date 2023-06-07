/**********************************************************
*
* bg_SBQQ_Helper :
*
* Created By: Daniel Trusler (Brightgen)
* Created Date: 24-08-2017
*
**********************************************************/

public class bg_SBQQ_Helper {

    // Method called by the bg_SBQQQuote_ai trigger
    //This sets fields in the SBQQ Quote, replacing the functionality of the old processes
  
    public static void setOppContacts(list<SBQQ__Quote__c> QuoteRecords) {
    	list<id> idList = new list<id>() ;
    	for(SBQQ__Quote__C quoterecord : QuoteRecords) {
    		idList.add(quoterecord.SBQQ__Opportunity2__c) ;
    	}
    	map<id,opportunity> oppMap = new map<id,opportunity>([select id, recordtypeid from opportunity where id in :idList]) ;
    	list<Opportunity> OppList = new list<Opportunity>() ;
    	 for (SBQQ__Quote__C quoterecord : QuoteRecords)
        {   
        	system.debug('helper step1') ;
        	//system.debug(oppmap.get(quoterecord.SBQQ__Opportunity2__c).recordtypeid) ;
        	system.debug(quoterecord.SBQQ__Opportunity2__c) ;
        	system.debug(quoterecord.SBQQ__Opportunity2__r.RecordTypeID) ;
        	system.debug(quoterecord.SBQQ__PrimaryContact__c) ;
        	system.debug(quoterecord.sbqq__Primary__c) ;
        	
            if(oppmap.containsKey(quoterecord.SBQQ__Opportunity2__c)){
                    if(oppmap.get(quoterecord.SBQQ__Opportunity2__c).recordtypeid == '012D0000000NaNlIAK' &&  quoterecord.SBQQ__PrimaryContact__c != null && quoterecord.sbqq__Primary__c == true ) {
                    
                    opplist.add(new opportunity(id=quoterecord.SBQQ__Opportunity2__c, Contact__c =quoterecord.SBQQ__PrimaryContact__c )) ;
                }
    
            }
        }
        
         system.debug(opplist) ;
         
        if(opplist.size() >0 ) {
        	update opplist ;
        }
        
       
        
    }
    
    public static void setFields(list<SBQQ__Quote__C> newQuotes){
    	

        list<SBQQ__Quote__C> returnQuotes = new list<SBQQ__Quote__C>();
        /*
            NOTE, THIS CODE WORKS ON THE ASSUMPTION THAT THERE IS ONLY ONE QUOTE PROCESS, WILL NEED TO BE UPDATED AS ADDITIONAL PROCESSES ARE SET
        */
        list<SBQQ__QuoteProcess__c> quoteProcesses = [SELECT Id FROM SBQQ__QuoteProcess__c];
        SBQQ__QuoteProcess__c quoteProcess = new SBQQ__QuoteProcess__c();
        if (!quoteProcesses.isEmpty())
        {
            quoteProcess = quoteProcesses[0];
        }

        for (SBQQ__Quote__C newQuote : newQuotes)
        {   
        	
            SBQQ__Quote__C returnQuote = new SBQQ__Quote__c(id=newQuote.Id);
            if (newQuote.Owner_Department__c != 'QMS')
            {
                returnQuote.SBQQ__QuoteProcessId__c = quoteProcess.Id;
            }
           /* if (newQuote.Owner_Department__c == 'QMS' && newQuote.Owner_Department__c != null)
            {
                returnQuote.SBQQ__BillingFrequency__c = 'Quarterly DD';
            }*/
            else if (newQuote.Owner_Department__c != null && newQuote.Owner_Department__c == 'Citation')
            {
                returnQuote.SBQQ__BillingFrequency__c = 'Monthly';
            }
            /*
            if (newQuote.SBQQ__PrimaryContact__c != null)
            {
                returnQuote.Customer_Signatory__c = newQuote.SBQQ__PrimaryContact__c; 
            }
            */
            
            if (newQuote.checkManagerIsNotNull__c)
            {
                returnQuote.Manager__c = newQuote.ownerManagerId__c;
            }
            returnQuote.SBQQ__LineItemsGrouped__c = true;
            returnQuotes.add(returnQuote);
        }
        if(!returnQuotes.isempty()){
        	update returnQuotes;    
        }
        
    }

    public list<SBQQ__Quote__C> updateTemplate(list<SBQQ__Quote__C> upQuotes){
        list<SBQQ__Quote__C> upLstSBQQ = new list<SBQQ__Quote__C>();
        set<id> idSet=new set<id>();
        Map<id, Account> accMap=new Map<id, Account>();
        for(SBQQ__Quote__C sbp: upQuotes){
           idSet.add(sbp.SBQQ__Account__c);  
        }        
        for(Account acc:[Select id,FT_Employees__c,PT_Employees__c,Sites__c from Account where id in :idSet]){
            accMap.put(acc.id,acc);
        }
        for(SBQQ__Quote__C sbp: upQuotes){
            system.debug('sbp'+sbp);
             if(sbp.recordtypeid == System.Label.CRQ_Locked_Record_Type){
                sbp.SBQQ__QuoteTemplateId__c = System.Label.Citation_Standard_Contract_Temp;
            }
            if(sbp.recordtypeid == system.label.CRQ_Standard_Record_Type){
                sbp.SBQQ__QuoteTemplateId__c = System.Label.CLR_Service_Proposal_Template;
            }
            if(sbp.SBQQ__Account__c !=null){
            sbp.Number_Of_Full_Time_Employees__c=accMap.get(sbp.SBQQ__Account__c).FT_Employees__c;
            sbp.Number_of_Part_Time_Employees__c=accMap.get(sbp.SBQQ__Account__c).PT_Employees__c;
            sbp.Number_of_Standard_Sites__c=accMap.get(sbp.SBQQ__Account__c).Sites__c;     
            }
            upLstSBQQ.add(sbp);
        }
        if(upLstSBQQ.size()>0){
            system.debug('updated the quote'+upLstSBQQ);
            return upLstSBQQ;
        }
        return null;
    }
}