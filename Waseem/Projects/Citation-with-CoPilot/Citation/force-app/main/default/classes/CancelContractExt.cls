public class CancelContractExt {
    
    public Contract contr {get;set;}
    public list<opportunity> oppList {get;set;}
    public sbqq__quote__c CPQQuote {get;set;}
    
    public boolean shouldRedirect           {get;set;}{shouldRedirect = false;}
    public string url                       {get;set;}
    public boolean HasCancelPermissions {get;set;}
    
    
    
    
    public CancelContractExt(ApexPages.StandardController controller) {
        contr = new contract() ;
        contr = null ;
        id userId = userinfo.getUserId() ;
        list<PermissionSetAssignment> psa = [Select Assignee.name, permissionSet.name, assignee.id from PermissionSetAssignment where Assignee.id = :userId and PermissionSet.label = 'Cancel Contracts'] ;
        HasCancelPermissions = false ;
       
        
         if (!Test.isRunningTest()) {
                controller.addFields(new List<String>{'Name','Id','Contract__c', 'RecordType.Name','SBQQ__Opportunity2__c','sbqq__QuoteTemplateId__c'});
         }
         
         CPQQuote = (sbqq__quote__c)controller.getrecord() ;
         
         if(CPQQuote.contract__C != null) {
            
                contr = [select id,startdate,enddate,name from contract where id = :CPQQuote.contract__c] ;
            
         }
         
          if(psa.size() >0 && CPQQuote.sbqq__QuoteTemplateId__c != null) {
            HasCancelPermissions = true ;
             opplist = new list<opportunity>() ;
             oppList = [select id,name,SBQQ__Contracted__c, contractid from opportunity where id = :CPQQuote.SBQQ__Opportunity2__c] ; 
        }   
        
       
         
    }
    
    
     public pagereference CancelContract() {
                recordtype QMS = [select id from recordtype where name = 'QMS Quote Approved' and sobjecttype = 'SBQQ__Quote__c'] ;
                recordtype STD = [select id from recordtype where name = 'Quote Standard' and sobjecttype = 'SBQQ__Quote__c'] ;
                recordtype CRR = [select id from recordtype where name = 'Client Relations Quote Standard' and sobjecttype = 'SBQQ__Quote__c'] ;
                
                list<note> nList = new list<note>() ;
                
                 opplist = new list<opportunity>() ;
                    oppList = [select id,name,SBQQ__Contracted__c, contract.id from opportunity where id = :CPQQuote.SBQQ__Opportunity2__c] ; 
                    
                try {
                        for(opportunity o : opplist) {
                            
                            o.sbqq__contracted__c = false ;
                            
                        }
                    
                        
                            CPQQuote.contract__c = null ;
                             if (!Test.isRunningTest()) {
                                    CPQQuote.sbqq__QuoteTemplateId__c = null ;
                             }
                            CPQQuote.contract_generated__c = false ;
                            CPQQuote.SBQQ__Status__c='Draft';
                            if(CPQQuote.recordtype.name == 'Quote Locked') {
                                CPQQuote.recordtypeid = STD.id ;
                            }
                            else if(CPQQuote.recordtype.name == 'QMS Quote Locked') {
                                CPQQuote.recordtypeid = QMS.id ;
                            }
                            else if(CPQQuote.recordtype.name == 'Client Relations Quote Locked')
                            {
                                CPQQuote.recordtypeid = CRR.id ; 
                            }
                            if(contr != null) {
                            nList.add(new note(
                                    title = 'Contract Cancelled',
                                    body = 'Contract starting ' + contr.startdate + ' and ending ' + contr.enddate + ' Cancelled by ' + userinfo.getfirstname() + ' ' + userinfo.getlastname() ,
                                    parentid = CPQQuote.id 
                                )) ;
                            } else
                            {  nList.add(new note(title = 'Contracting Undone',body = 'Failed Contract Process Undone Cancelled by ' + userinfo.getfirstname() + ' ' + userinfo.getlastname() ,parentid = CPQQuote.id )) ;
                            }
                        
                    
                        update CPQQuote ;
                        update opplist ;
                        if(contr != null) {delete contr ; }
                        if(nlist.size() >0) {
                            insert nlist ;
                        }
                        
                        
                        ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Info,'Contract has been removed.') ;
                        ApexPages.AddMessage(message) ;
                        url = '/' + CPQQuote.id ;
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