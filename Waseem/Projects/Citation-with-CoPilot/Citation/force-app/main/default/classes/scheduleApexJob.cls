public class scheduleApexJob {
    public static void scheduleDialListCriteriaFieldsBatch(String classname){      
        String Classnm = classname;
        Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
        if(myCSList != NULL && Classnm != NULL && myCSList.containskey(Classnm) && myCSList.get(Classnm).Schedule_Time__c != NULL){
        List<String> sctime = myCSList.get(Classnm).Schedule_Time__c.split(':');
        Integer admonths = integer.valueOf(sctime[0]);
        Integer addays = integer.valueOf(sctime[1]);
        Integer runhour = integer.valueOf(sctime[2]);
		Integer runmin = integer.valueOf(sctime[3]); 
        if(admonths == 0 && addays == 0 && (runhour < system.now().hour() || (runhour == system.now().hour()
                                                                              && runmin <= system.now().minute() )) ){
        	addays = 1; 
		}
        datetime dt = system.now().addmonths(admonths).adddays(addays);
        String day = string.valueOf(dt.day());
        String month = string.valueOf(dt.month());
        String hour = sctime[2];
        String minute = sctime[3];
        String second = sctime[4];
        String year = string.valueOf(dt.year());
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
         system.debug('-->' + strSchedule);
        List<CronTrigger> ctList= new List<CronTrigger>();
        Integer batchsize = 200;
            if(myCSList.get(Classnm).Batch_size__c != NULL){
                batchsize = Integer.valueof(myCSList.get(Classnm).Batch_size__c);
            }
         String jn = 'DialListCriteriaFieldsBatch' + '-' + year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second ; 
        if(myCSList.get(Classnm).singleRun__c){
           String vclassname = Classnm + '%'; 
           ctList =  [SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State FROM CronTrigger where CronJobDetail.Name LIKE :vclassname AND State !='COMPLETE' AND State !='Aborted' AND State != 'Failed' AND state != 'DELETED'];    
            if(ctList.isEmpty()){
                if(Classnm == 'DialListCriteriaFieldsBatch'){
                    DialListCriteriaFieldsBatch sc = new DialListCriteriaFieldsBatch();
                    sc.BatchSize = batchsize;
                    system.schedule(jn, strSchedule, new DialListCriteriaFieldsBatch());
                }
            }
        }else {
            if(Classnm == 'DialListCriteriaFieldsBatch'){
                    DialListCriteriaFieldsBatch sc = new DialListCriteriaFieldsBatch();
                    sc.BatchSize = batchsize;
                    system.schedule(jn, strSchedule, new DialListCriteriaFieldsBatch());
                }       
        }
       }
    }
}