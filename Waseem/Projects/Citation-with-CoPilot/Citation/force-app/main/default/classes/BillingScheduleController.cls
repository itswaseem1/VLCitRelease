public  class BillingScheduleController {
	/* ffbc__BillingSchedule__c */
	
    public ffbc__Contract__c contractRecord{get;set;}
    
    public List<ffbc__BillingSchedule__c> ScheduleItems {get;set;}
	Id ContractId {get;set;}
	public string ContractName {get;set;}
	public string Street {get;set;} 
	public	string City  {get;set;} 
	public	string State {get;set;} 
	public	string Postcode  {get;set;}
	public string CustomerAccount {get;set;} 
	
	public Set<string> ProductNameSet {get;set;}
	public List<string> ProductNameList {get;set;}
	public Map<string,List<ffbc__BillingSchedule__c>> Schedule {get;set;}
	
	public List<string> spacer {get;set;}
	public static Boolean runningInSandbox() {
		return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}
	
	private static OrgWideEmailAddress owea {
		get;
		set {
			try{
				owea = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: System.Label.FF_VAT_Billing_Schedule_ReplyTo_Email limit 1];
			}catch(Exception ex){
				System.debug('Error: ' + ex.getMessage());
			}
		}
	}

	public BillingScheduleController(ApexPages.StandardController standardController) {
		
		 Street = '' ;
		 City  = '' ;
		 State  = '' ;
		 Postcode  = '' ;
		
		 if (!Test.isRunningTest()) {
			    	standardController.addFields(new List<String>{'Name','Id','ffbc__Account__r.Name','ffbc__Account__r.billingstreet', 'ffbc__Account__r.billingcity', 'ffbc__Account__r.billingstate', 'ffbc__Account__r.billingpostalcode', 'ffbc__Account__r.billingcountry','ffbc__Account__r.Sage_Id__c','ffbc__Account__r.QMSClientCheck__c','VAT_Schedule_Start__c','VAT_Schedule_End__c','VAT_Schedule_Last_Start__c','VAT_Schedule_Last_End__c','ffbc__company__r.name'});					
		 }
    	 contractRecord = (ffbc__Contract__c)standardController.getRecord();
       	 ContractId = contractRecord.id;
       	 ContractName = contractRecord.Name ;
       	 if(ContractRecord.ffbc__Account__r.billingStreet != null) {       	 	Street = ContractRecord.ffbc__Account__r.billingstreet.replace(',','<br/>') + '<br/>';       	 }
       	 if(ContractRecord.ffbc__Account__r.billingCity != null) {       	 	City = ContractRecord.ffbc__Account__r.billingcity.replace(',','<br/>')  + '<br/>';       	 }
       	 
       	 if(ContractRecord.ffbc__Account__r.billingState != null) {       	 	 State = ContractRecord.ffbc__Account__r.billingstate.replace(',','<br/>')   + '<br/>';       	 }
       	 
       	 if(ContractRecord.ffbc__Account__r.BillingPostalCode != null) {       	 	 Postcode = ContractRecord.ffbc__Account__r.billingpostalcode.replace(',','<br/>') + '<br/>';       	 }
       	 
       	 if(ContractRecord.ffbc__account__r.Sage_Id__c != null) {       	 	CustomerAccount = ContractRecord.ffbc__account__r.Sage_Id__c ;   	 }
       	 else{
       	 	CustomerAccount = ContractRecord.id ;
       	 }
       	
       	date startdate = date.today() ;
       	date enddate = Date.newInstance(startdate.year()+1, startdate.month(), startdate.Day());
       	
       	if(ContractRecord.VAT_Schedule_Start__c != null ) {
       		startdate = ContractRecord.VAT_Schedule_Start__c ;
       		
       	}
       	
      		if( ContractRecord.VAT_Schedule_End__c != null) {
       		
       		enddate = ContractRecord.VAT_Schedule_End__c ;
       		 
       	} else
       		{
       			enddate = Date.newInstance(startdate.year()+1, startdate.month(), startdate.Day());
       		}
        ScheduleItems = [select id, name,ffbc__BillingDate__c,ffbc__ContractGrouping__c, 	ffbc__Value__c, ffbc__ContractLineItem__r.ffbc__Contract__r.ffbc__ContractName__c,ffbc__ContractLineItem__r.ffbc__Contract__r.id,ffbc__ContractLineItem__r.ffbc__ProductService__r.name,ffbc__ContractLineItem__r.ffbc__Contract__r.ffbc__Account__r.c2g__CODAOutputVATCode__r.Name from ffbc__billingSchedule__c where    ffbc__ContractLineItem__r.ffbc__Contract__r.id = :ContractId and ffbc__BillingDate__c >= :startdate and ffbc__BillingDate__c < :enddate  order by ffbc__ContractLineItem__r.ffbc__ProductService__r.name,ffbc__BillingDate__c ] ;
       	ProductNameSet = new Set<string>() ;
       	Schedule = new Map<string,list<ffbc__billingSchedule__c>>() ;
       	for(ffbc__billingSchedule__c bs : ScheduleItems) {
       		ProductNameSet.add(bs.ffbc__ContractLineItem__r.ffbc__ProductService__r.name) ;
       		Schedule.put(bs.ffbc__ContractLineItem__r.ffbc__ProductService__r.name,new List<ffbc__billingSchedule__c>()) ;
       	}
       	
       	List<ffbc__billingSchedule__c> items = new List<ffbc__billingSchedule__c>() ;
       	
       	for(ffbc__billingSchedule__c bs : ScheduleItems) {
       		items = Schedule.get(bs.ffbc__ContractLineItem__r.ffbc__ProductService__r.name) ;
       		items.add(bs) ;
       		Schedule.put(bs.ffbc__ContractLineItem__r.ffbc__ProductService__r.name,items) ;
       	}
       	ProductNameList = new List<string>() ;
       	if(ProductNameSet.size() >0) {
       		ProductNameList.addAll(ProductNameSet) ;
       	}
       	
        spacer = new list<string>() ;
         
       	if(ScheduleItems.size() < 12 ) {
       		for(Integer i = 1; i < 12 - ScheduleItems.size() ; i++) {
       			spacer.add('<p/>') ;
       		}
       	}
	}
       	 	
    public static void SendBillingSchedule(id ContractId, string filename) {
		ffbc__contract__C c = [select name, id, ffbc__account__r.name, ffbc__account__r.c2g__CODAInvoiceEmail__c,ffbc__account__r.Sage_Id__c,ffbc__Account__r.QMSClientCheck__c, ffbc__company__r.name from ffbc__contract__c where id = :contractId] ;
		attachment att = [select name, body from attachment where parentid = :contractId and name = :filename LIMIT 1] ;
		string htmlBody = '' ;
		string subjectline = '' ;
		string EmailAddress = '' ;
        string imsrQ = label.QMS_VAT_Schedule_Signature +'></img>';
		
			subjectLine = 'Your Citation ISO Certification VAT Schedule' ;
			htmlBody = 'Dear Customer,<br/><br/>' ;
			htmlbody += 'Your client reference: ' + c.name + '<br/><br/>' ;
			htmlbody += 'Please find your latest, annual VAT schedule attached.<br/><br/>' ;
			htmlbody += 'If you have any queries regarding your schedule, please get in touch with us on creditcontrol@citation.co.uk and we\'ll get back to you within 48 hours.<br/><br/>' ;
			htmlbody += '<img align="left" style="padding-left:5px;" src ='+imsrQ+'<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>';
		if(c.ffbc__company__r.name == 'Citation Limited') {
			string imsr = label.Citation_VAT_Schedule_Signature +'></img>';
			subjectLine = 'Your Citation VAT schedule' ;
			htmlBody = 'Dear Customer,<br/><br/>' ;
			htmlbody += 'Your client reference: ' + c.name + '<br/><br/>' ;
			htmlbody += 'Please find your latest, annual VAT schedule attached.<br/><br/>' ;
			htmlbody += 'If you have any queries regarding your schedule, please get in touch with us on creditcontrol@citation.co.uk and we\'ll get back to you within 48 hours.<br/><br/>' ;
			htmlbody += '<img align="left" style="padding-left:5px;" src ='+imsr+'<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>';
		}
		
		EmailAddress = UserInfo.getUserEmail() ;
		
		if(!RunningInSandbox()) {
			if(c.ffbc__account__r != null  && c.ffbc__account__r.c2g__CODAInvoiceEmail__c != null) {
				EmailAddress = c.ffbc__account__r.c2g__CODAInvoiceEmail__c ;
			}
			else
			{
				SubjectLine = System.Label.FF_VAT_Billing_Schedule_Email_Subject + ' ' + c.ffbc__account__r.name ;
				EmailAddress = UserInfo.getUserEmail() ;
			}
							
		} else {
			htmlBody += ' <br/><br/>Note : This would have been sent to : ' + c.ffbc__account__r.c2g__CODAInvoiceEmail__c ;
		}

		try{
			Messaging.SingleEmailMessage semail= new Messaging.SingleEmailMessage();
			Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
			attach.setBody(att.body);
			attach.setfilename(att.name) ;
			
			semail.setSubject(subjectLine);
			String[] emailIds= new String[]{EmailAddress};
			semail.setToAddresses(emailIds);
			if(owea != null) semail.setOrgWideEmailAddressId(owea.Id);
			semail.setHtmlBody(htmlbody);
			semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
		} catch (Exception ex){
			System.debug('Error: ' + ex.getMessage());
		}
		
	}
	
	
	@future(callout=true)
	public static void GenerateScheduleFiles(List<id> idList) {
		string FileName = '' ;
		List<attachment> attachList = new List<attachment>() ;
		List<ffbc__contract__c> contractList = new List<ffbc__contract__c>() ;
		Map<id,ffbc__Contract__c> ContractMap = new Map<id,ffbc__Contract__c>([select id, VAT_schedule_start__c, VAT_schedule_end__c from ffbc__Contract__c where id in :idList ]) ;
		
		PageReference pdf = Page.BillingSchedule ;
		Attachment attach = new Attachment() ;
		blob body ;
	
		for(id i : idList) {
			fileName = '' ;
    		fileName += 'VATSchedule_' + string.valueof(system.now().year()) + '_' + string.valueof(system.now().month()) + '_' + string.valueof(system.now().day()) + '_' + string.valueof(system.now().hour()) + '_' + string.valueof(system.now().minute()) + '.pdf';
    			
			pdf.getParameters().put('id',i) ;
			
			if (Test.IsRunningTest())
			   {
			        body=Blob.valueOf('UNIT.TEST');
			   }
			   else
			   {
			        body = pdf.getContent() ;
			   }

			attach = null ;
			attach = new Attachment() ;
			Attach.body = body ;
    		attach.name = filename ;
    		attach.parentId = i ;
    		AttachList.add(attach) ;
    		contractList.add(new ffbc__contract__c(id=i,VAT_schedule_Filename__c=filename,VAT_Schedule_FileDate__c = system.now(), VAT_schedule_last_start__c = contractmap.get(i).VAT_schedule_start__c, VAT_schedule_last_end__c = contractmap.get(i).VAT_schedule_end__c    )) ;
		}
		
		insert AttachList ;
		update contractList ;
		
		Schedulable_BillingScheduleSender sched = new Schedulable_BillingScheduleSender() ;
		sched.dosend() ;
	}


	
	public static void GenerateScheduleFilesSynchronous(List<id> idList) {
		string FileName = '' ;
		List<attachment> attachList = new List<attachment>() ;
		List<ffbc__contract__c> contractList = new List<ffbc__contract__c>() ;
		Map<id,ffbc__Contract__c> ContractMap = new Map<id,ffbc__Contract__c>([select id, VAT_schedule_start__c, VAT_schedule_end__c from ffbc__Contract__c where id in :idList ]) ;
		
		PageReference pdf = Page.BillingSchedule ;
		Attachment attach = new Attachment() ;
		blob body ;
		for(id i : idList) {
			fileName = '' ;
    		fileName += 'VATSchedule_' + string.valueof(system.now().year()) + '_' + string.valueof(system.now().month()) + '_' + string.valueof(system.now().day()) + '_' + string.valueof(system.now().hour()) + '_' + string.valueof(system.now().minute()) + '.pdf';
    			
			pdf.getParameters().put('id',i) ;
			
			if (Test.IsRunningTest())
			   {
			        body=Blob.valueOf('UNIT.TEST');
			   }
			   else
			   {
			        body = pdf.getContent() ;
			   }
			attach = null ;
			attach = new Attachment() ;
			Attach.body = body ;
    		attach.name = filename ;
    		attach.parentId = i ;
    		AttachList.add(attach) ;
    	    contractList.add(new ffbc__contract__c(id=i,VAT_schedule_Filename__c=filename,VAT_Schedule_FileDate__c = system.now(), VAT_schedule_last_start__c = contractmap.get(i).VAT_schedule_start__c, VAT_schedule_last_end__c = contractmap.get(i).VAT_schedule_end__c    )) ;
		}
		
		insert AttachList ;
		update contractList ;
		
		Schedulable_BillingScheduleSender sched = new Schedulable_BillingScheduleSender() ;
		sched.dosend() ;
		
	}
}