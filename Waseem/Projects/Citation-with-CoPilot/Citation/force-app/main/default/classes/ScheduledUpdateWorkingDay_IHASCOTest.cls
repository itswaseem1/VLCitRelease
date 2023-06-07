@istest
public class ScheduledUpdateWorkingDay_IHASCOTest {
   static testmethod void testSameMonth() {
   Test.startTest();
   list<holiday>     holidayList = new list<holiday>();
    date dt = date.today();
    date dt1 = dt.toStartOfMonth();
   holidayList = [select id,Name, ActivityDate,RecurrenceMonthOfYear from Holiday where activitydate >: dt1  order by ActivityDate DESC];   
   /*for(integer i=1;i<11;i++){
        holiday hl = new holiday();
        hl.Name = 'Holiday '+ i;
        hl.ActivityDate = Date.Today()+i;
        hl.description = 'Holiday '+i;
        holidayList.add(hl);
    } 
 
    insert holidayList;*/

    Month_Day__c md = new Month_Day__c();
    md.name = string.valueof(DATE.TODAY().MONTH());
    md.Current_Working_Day_in_the_Month__c = 1;
    insert md;

    list<Month_Year__c>       MonthYearList  = new list<Month_Year__c>();

    for(integer i=0;i<12;i++)
    {
        Month_Year__c myr = new Month_Year__c();
        myr.name = String.valueof(date.today().toStartOfMonth().year())+'/'+String.valueof(date.today().toStartOfMonth().month());
        MonthYearList.add(myr);
    }
    insert MonthYearList;
       
    list<Calendar_Month__c>      cmList = new list<Calendar_Month__c>();
    Calendar_Month__c    cm = new Calendar_Month__c();
    cm.name = 'Srikanth Ragi';
    cm.Number_of_Days_Present_in_the_Month__c = 17;
    cm.Number_of_Days_in_the_Month__c = 23;   
    insert cm;
    // Schedule the test job

    String jobId = System.schedule('ScheduledToRunWorkingDay','0 10 18 ? * MON-FRI',new ScheduledRuntoUpdateWorkingDay_IHASCO());

       
   Test.stopTest();

   }
    
   static testmethod void testDiffMonth() {
   Test.startTest();
   list<holiday>     holidayList = new list<holiday>();
    date dt = date.today();
    date dt1 = dt.toStartOfMonth();
   holidayList = [select id,Name, ActivityDate,RecurrenceMonthOfYear from Holiday where activitydate >: dt1  order by ActivityDate DESC];   
   /*for(integer i=1;i<11;i++){
        holiday hl = new holiday();
        hl.Name = 'Holiday '+ i;
        hl.ActivityDate = Date.Today()+i;
        hl.description = 'Holiday '+i;
        holidayList.add(hl);
    } 
 
    insert holidayList;*/

    Month_Day__c md = new Month_Day__c();
    md.name = string.valueof(DATE.TODAY().MONTH()-1);
    md.Current_Working_Day_in_the_Month__c = 1;
    insert md;

    list<Month_Year__c>       MonthYearList  = new list<Month_Year__c>();

    for(integer i=0;i<12;i++)
    {
        Month_Year__c myr = new Month_Year__c();
        myr.name = string.valueof(Date.Today().year())+'/'+string.valueof(Date.Today().month());
        MonthYearList.add(myr);
    }
    insert MonthYearList;
       
    list<Calendar_Month__c>      cmList = new list<Calendar_Month__c>();
    Calendar_Month__c    cm = new Calendar_Month__c();
    cm.name = 'Srikanth Ragi';
    cm.Number_of_Days_Present_in_the_Month__c = 17;
    cm.Number_of_Days_in_the_Month__c = 23;   
    insert cm;
    // Schedule the test job

    String jobId = System.schedule('ScheduledToRunWorkingDay','0 10 18 ? * MON-FRI',new ScheduledRuntoUpdateWorkingDay_IHASCO());

       
   Test.stopTest();

   }
}