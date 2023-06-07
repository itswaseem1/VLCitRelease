global class Schedulable_BillingScheduleSender implements Schedulable {
    
    
    global void execute(SchedulableContext SC) {
    	
    	doSend() ;
    }
    
    public void doSend() {
	list<ffbc__contract__c> contractList = [select id, VAT_schedule_filename__c from ffbc__contract__c where VAT_schedule_filename__c <> '' and VAT_schedule_filename__c <> null limit 10] ;
    	
    	if(contractList.size() >0 ) {
    		for(ffbc__contract__c c : contractList) {
    			BillingScheduleController.SendBillingSchedule(c.id,c.VAT_schedule_filename__c) ;
    			c.VAT_schedule_filename__c = '' ;
    			c.VAT_schedule_sent_date__c = system.now() ;
    		}
    		update contractList ;
    		
    		
    		list<ffbc__contract__c> contractListRemaining = [select id, VAT_schedule_filename__c from ffbc__contract__c where VAT_schedule_filename__c <> '' and VAT_schedule_filename__c <> null limit 10] ;
    		
    		datetime dd = system.now() ;
    			dd= dd.addminutes(1) ;
    			 String day = string.valueOf(dd.day());
            	String month = string.valueOf(dd.month());
            	String hour = string.valueOf(dd.hour());
            	String minute = string.valueOf(dd.minute() ) ; // + 1);
            	String second = string.valueOf(dd.second());
            	String year = string.valueOf(dd.year());
            	
            	 integer STRING_LENGTH = 3;
 				double MAX = Math.pow(10,STRING_LENGTH) - 1; // Returns 999
				String randomNum = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
            	
            	 String strJobName = 'ScheduleSender -(rnd' + randomNum +  ')' +  second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
         	   String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
    		
    		if(contractListRemaining.size() >0) {
    		try{
    			  System.schedule(strJobName, strSchedule, new Schedulable_BillingScheduleSender());
    		}		
    		catch (Exception ex) {
    			
    		}
          
    		}
    		
    	}
    }
}