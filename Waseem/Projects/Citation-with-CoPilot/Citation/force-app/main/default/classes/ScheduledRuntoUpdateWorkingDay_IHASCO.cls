global class ScheduledRuntoUpdateWorkingDay_IHASCO implements Schedulable {

   global void execute(SchedulableContext ctx) {
    
    integer holidaysCount =0;
    boolean newmonth = false;
    date dt = date.today();
    date dt1 = dt.toStartOfMonth();

    list<holiday>    hlList   = [select id,Name, ActivityDate,RecurrenceMonthOfYear from Holiday where activitydate >: dt1  order by ActivityDate DESC];
    Month_Day__C     monthDay = [select id, Current_Working_Day_in_the_Month__c,name  from Month_Day__c limit 1];
    
    if(string.valueof(dt.month()) != monthDay.name){
        newmonth = true;    
    }
    
    for(holiday hl: hlList){
        if(hl.ActivityDate == dt ){
            holidaysCount ++;
        }
    }
    
    if(!(holidaysCount > 0)){
        if(newmonth){
            monthDay.Current_Working_Day_in_the_Month__c = 0;
        }
        if(monthDay.Current_Working_Day_in_the_Month__c != null){
                monthDay.Current_Working_Day_in_the_Month__c = monthDay.Current_Working_Day_in_the_Month__c+1;
                monthDay.name = string.valueof(dt.month());
        }
        else{
                monthDay.Current_Working_Day_in_the_Month__c = 1;
                monthDay.name = string.valueof(dt.month());
        }
    }                                                                                       
    
    update monthDay;
    string dtYear = string.valueof(date.today().year());
    list<Calendar_Month__c>    lstCalMonth   = new list<Calendar_Month__c>();
    id monthyearid;
    if(newmonth){
        
        lstCalMonth  = [select id,name,Month_Year__c from Calendar_Month__c] ;
        list<Month_Year__c>    lstMonth_Year = [select id,Name from Month_Year__c where name like: dtYear+'%'];
        string newmonthName = string.valueof(Date.Today().month());
        string monthYearStr = string.valueof(Date.Today().year())+'/'+string.valueof(Date.Today().month());       
        for(Month_Year__c    my: lstMonth_Year){
            if(my.name == monthYearStr){
                monthyearid = my.id;
            }
        }
    }

    for(Calendar_Month__c clf: lstCalMonth){
        if(monthyearid != null){
            clf.Month_Year__c = monthyearid;
        }
    }
   
    if(newmonth && lstCalMonth.size()>0){
        update lstCalMonth;
    }   

    }   
}