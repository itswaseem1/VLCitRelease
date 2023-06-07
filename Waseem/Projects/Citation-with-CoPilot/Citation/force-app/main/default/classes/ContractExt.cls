public class ContractExt {
	
	public Contract contr {get;set;}
	public list<opportunity> oppList {get;set;}
	public list<sbqq__quote__c> qList {get;set;}
	
	public boolean shouldRedirect           {get;set;}{shouldRedirect = false;}
    public string url                       {get;set;}
    public boolean HasCancelPermissions {get;set;}
    
    public ContractExt (ApexPages.StandardController controller) {
    	id userId = userinfo.getUserId() ;
    	 list<PermissionSetAssignment> psa = [Select Assignee.name, permissionSet.name, assignee.id from PermissionSetAssignment where Assignee.id = :userId and PermissionSet.label = 'Cancel Contracts'] ;
        HasCancelPermissions = false ;
        if(psa.size() >0) {
            HasCancelPermissions = true ;
        }	
    	
    	 if (!Test.isRunningTest()) {
				controller.addFields(new List<String>{'Name','Id','AccountId','StartDate','EndDate'});
		 }
    	contr = (Contract)controller.getrecord() ;
    	qlist = new list<sbqq__quote__c>() ;
    	opplist = new list<opportunity>() ;
    	
    	qList = [select id, contract__c,SBQQ__QuoteTemplateId__c, recordtype.name, recordtypeid from sbqq__quote__c where contract__c = :contr.id] ;
    	
    	 oppList = [select id,name,SBQQ__Contracted__c, contractid from opportunity where contractid = :contr.id] ; 
    }
    
    
    public pagereference CancelContract() {
    			recordtype QMS = [select id from recordtype where name = 'QMS Quote Approved' and sobjecttype = 'SBQQ__Quote__c'] ;
    			recordtype STD = [select id from recordtype where name = 'Quote Approved' and sobjecttype = 'SBQQ__Quote__c'] ;
    			list<note> nList = new list<note>() ;
    			
    		 	
                    
                try {
	                	for(opportunity o : opplist) {
	                		o.sbqq__contracted__c = false ;
	                		o.contractid = null ;
	                	}
                	
	                	for(sbqq__quote__c q : qlist) {
	                		q.contract__c = null ;
	                		q.sbqq__QuoteTemplateId__c = null ;
                            q.contract_generated__c = false ;
                            if(q.recordtype.name == 'Quote Locked') {
                            	q.recordtypeid = STD.id ;
                            }
                            else if(q.recordtype.name == 'QMS Quote Locked') {q.recordtypeid = QMS.id ; }
                            nList.add(new note(
                            		title = 'Contract Cancelled',
                            		body = 'Contract starting ' + contr.startdate + ' and ending ' + contr.enddate + ' Cancelled by ' + userinfo.getfirstname() + ' ' + userinfo.getlastname() ,
                            		parentid = q.id 
                            	)) ;
	                	}
                	
	                	update qlist ;
	                	update opplist ;
	                	delete contr ;
	                	if(nlist.size() >0) {
	                		insert nlist ;
	                	}
	                	
	                	url = '/' + contr.accountid ;
	              		ShouldRedirect = true ;
	              		return null ;
                	
                	
               		 }
	                catch (Exception ex) {
	                	ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Error,'An Error ocurred during cancel attempt :' + ex.getmessage()) ;
	                    ApexPages.AddMessage(message) ;
	                    return null ;
	                }
    		
    }
    
}