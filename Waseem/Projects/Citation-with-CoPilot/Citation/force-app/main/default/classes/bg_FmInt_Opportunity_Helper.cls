/********************************************************************************
* bg_FmInt_Opportunity_Helper :
*
* Helper class for the Opportunity object.
*
* Created By: SA
* Created Date: 02-03-2016 
*
* Changes: KH 20-06-2017 - Adding in additional check for QMS Products
*********************************************************************************/
public with sharing class bg_FmInt_Opportunity_Helper
{
	/*
		Called from after insert trigger.
		Send to FM if Opp has a FM id
	*/
	public static void synchronise(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap)
	{
	    List<Opportunity> oppSendList = new List<Opportunity>();
	    List<Opportunity> oppSendListA = new List<Opportunity>();

	    for (Opportunity o : opportunities)
	    {
	    	// check that Opportunity has QMS Products or Not
	     	//Boolean hasQMSProducts = o.Number_of_QMS_Products__c > 0;

            if(oldMap.get(o.Id).Sale_Approved__c != o.Sale_Approved__c && o.Sale_Approved__c && (o.Number_of_QMS_Products__c > 0 || o.Certification__c != null))
            {
	    		// Sale_Approved__c has transitioned from not checked to checked
	    		// Activate
                oppSendListA.add(o);
            }
	    	else if((o.FM_Opportunity_External_Id__c != null) && (oldMap.get(o.Id).FM_Opportunity_External_Id__c == o.FM_Opportunity_External_Id__c))
	    	{
	    		// only update if FM_Opportunity_External_Id__c is set AND no change in ext_ids
               	oppSendList.add(o);
			}
	    }

	    if(oppSendList.size()>0)
            bg_FmIntOpportunity.send(oppSendList);

	    if(oppSendListA.size()>0)
            bg_FmIntOpportunity.send('Activate', oppSendListA);

	}
      public static void opportunityELASEmail(List<Opportunity> oppList){        
        Map<Id,List<OpportunityLineItem>> oppItemMap=new Map<Id,List<OpportunityLineItem>>();
        List<Opportunity> opportunityList=new List<opportunity>();       
        Map<Id,SBQQ__Quote__c> quoteMap=new Map<Id,SBQQ__Quote__c>();
        
        
        opportunityList=[Select Id,Name,OwnerId,Owner.Name,AccountId,Account.Name,Account.Legacy_Migration_system_id_s__c,(Select Id,Product2.Name From OpportunityLineItems) 
                         From Opportunity where id =:oppList];
        for(Opportunity oppty: opportunityList){
            oppItemMap.put(oppty.Id,oppty.OpportunityLineItems);
        }
        
        for(SBQQ__Quote__c qut:[Select Id,Contract__c,Contract__r.Name,Contract__r.StartDate,SBQQ__Opportunity2__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c=:oppList AND Contract__c!=null AND SBQQ__Primary__c=TRUE]){
            quoteMap.put(qut.SBQQ__Opportunity2__c,qut);
        }
        
        Messaging.SingleEmailMessage message;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        String address=System.Label.ZainEmailAddress;  
        String line1 = '<html><body>Hi Zain,<br><br></body></html>';   
        String line2;
        String line3;
        String line4;       
        String line5 = '<html><body>- cancel all/part of current ELAS order as the client is now on a Citation contract, or raise a credit note etc.<br><br></body></html>';       
        String line6 = '<html><body>&nbsp&nbsp </body></html>';   
        String line7 = '<html><body>Regards,<br></body></html>';
        String line8 = '<html><body>Client Relations<br></body></html>';  
        String productNames;
        String contractDate;
        
        for(Opportunity opp:opportunityList){
            productNames=''; 
            contractDate='';
            if(oppItemMap.containsKey(opp.id)){
                for(OpportunityLineItem oppitem: oppItemMap.get(opp.id)){
                    System.debug('oppitem:'+ oppitem.Product2.Name);
                    productNames+=oppitem.Product2.Name+',';
                }
            }
            productNames=productNames.removeEnd(',');
            if(quoteMap.containsKey(opp.id)){
                contractDate= (quoteMap.get(opp.id).Contract__r.StartDate).format();
            }
            System.debug('contractDate:'+contractDate);
            line2 = '<html><body>The '+opp.Name+' has been staged to Closed Won by '+opp.Owner.Name+' .<br><br></body></html>'; 
            line3 = '<html><body>The ELAS system reference is '+ opp.Account.Name+'/'+opp.Account.Legacy_Migration_system_id_s__c+'.<br><br></body></html>';
            line4 = '<html><body>The Citation contract start date will be '+ contractDate+' for '+ productNames+'.<br><br></body></html>';
            
            message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{address};
            message.subject = opp.Account.Name+' ELAS Opportunity has been won';
            message.HtmlBody = line1+line2+line3+line4+line5+line6+line7+line8;
            message.setWhatId(opp.Id);
            messages.add(message);
            
        }
        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            for(Messaging.SendEmailResult sendEmailResult : results){
                if(!sendEmailResult.success){
                    for(Messaging.SendEmailError err : sendEmailResult.getErrors()) {
                        System.debug('The following error has occurred---'+err.getStatusCode() + ': ' + err.getMessage()+'-:-'+err.getFields());
                    }
                }
            }
        }
    } 
}