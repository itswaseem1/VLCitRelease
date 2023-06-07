public with sharing class BusinessHoursCalculator { //
	
 private static List<Boolean> businessDay = new Boolean[7];
 private static List<Time> startHours = new Time [7];
 private static List<Time> endHours = new Time [7];
 private static Date knownSunday = date.newInstance(2013, 1, 6);
 
   
    public BusinessHoursCalculator() {
        
        Integer index = 0;
        BusinessHours bhObj = new BusinessHours();
        bhObj =[Select SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime, //NOPMD
                WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                From BusinessHours 
                Where Name='UK Business Hours']; 
        
        businessDay[index] = (bhObj.SundayStartTime != null);
        businessDay[index+ 1] = (bhObj.MondayStartTime != null);
        businessDay[index + 2] = (bhObj.TuesdayStartTime != null);
        businessDay[index + 3] = (bhObj.WednesdayStartTime != null);
        businessDay[index + 4] = (bhObj.ThursdayStartTime != null);
        businessDay[index + 5] = (bhObj.FridayStartTime != null);
        businessDay[index + 6] = (bhObj.SaturdayStartTime != null);
        
        startHours[index + 0] = bhObj.SundayStartTime;
        startHours[index + 1] = bhObj.MondayStartTime;
        startHours[index + 2] = bhObj.TuesdayStartTime;
        startHours[index + 3] = bhObj.WednesdayStartTime;
        startHours[index + 4] = bhObj.ThursdayStartTime;
        startHours[index + 5] = bhObj.FridayStartTime;
        startHours[index + 6] = bhObj.SaturdayStartTime;
        
        endHours[index + 0] = bhObj.SundayEndTime;
        endHours[index + 1] = bhObj.MondayEndTime;
        endHours[index + 2] = bhObj.TuesdayEndTime;
        endHours[index + 3] = bhObj.WednesdayEndTime;
        endHours[index +4] = bhObj.ThursdayEndTime;
        endHours[index +5] = bhObj.FridayEndTime;
        endHours[index + 6] = bhObj.SaturdayEndTime;

   }

   // Check if today is a business day
   public Boolean isBusinessDay(Date inputDate) {
     // index i is index into the businessDay array based on inputDate
     Integer i = Math.mod(Math.abs(knownSunday.daysBetween(inputDate)),7);
     return (businessDay[i]);
    }
  
   // Get the start time
   public Time getStartTime(DateTime inputDate) {
    Integer i = Math.mod(Math.abs(knownSunday.daysBetween(inputDate.date())),7);
     return (startHours[i]);
   }

   // Gets next business day, skipping non business days
  public Date nextBusinessDay(Datetime inputDatetime) {
    Integer i = 
      Math.mod(Math.abs(knownSunday.daysBetween(inputDatetime.date())),7);
    Datetime returnDate = inputDatetime;
    while (!businessDay[Math.mod(i, 7)]) {
       i++;
       returnDate = returnDate.addDays(1);
    }
   return returnDate.date();
 }

}