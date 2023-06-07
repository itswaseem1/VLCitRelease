public class BDMAllocationJSON2Apex {

  public class AvailableTimeSlots {
    public Integer Score {get;set;} 
    public String Day {get;set;} 
    public String Date_Z {get;set;} // in json: Date
    public String Slot_Start_Time {get;set;} 
    public String Slot_End_Time {get;set;} 

    public AvailableTimeSlots(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'Score') {
              Score = parser.getIntegerValue();
            } else if (text == 'Day') {
              Day = parser.getText();
            } else if (text == 'Date') {
              Date_Z = parser.getText();
            } else if (text == 'Slot_Start_Time') {
              Slot_Start_Time = parser.getText();
            } else if (text == 'Slot_End_Time') {
              Slot_End_Time = parser.getText();
            } else {
              System.debug(LoggingLevel.WARN, 'Available Time Slots consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  
  public String OpportunityId {get;set;} 
  public String ClientName {get;set;} 
  public String ClientPostCode {get;set;} 
  public String ClientRegion {get;set;} 
  public String Sector {get;set;} 
  public String MadeCriteria {get;set;} 
  public String ProspectSource {get;set;} 
  public String MarketingChannel {get;set;} 
  public String AppointmentType {get;set;} 
  public String FTE {get;set;} 
  public Integer BookingLength {get;set;} 
  public List<BDM> BDM {get;set;} 
    public String RequestId {get;set;} 

  public BDMAllocationJSON2Apex(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'Opportunity Id') {
            OpportunityId = parser.getText();
          } else if (text == 'Client Name') {
            ClientName = parser.getText();
          } else if (text == 'Client PostCode') {
            ClientPostCode = parser.getText();
          } else if (text == 'Client Region') {
            ClientRegion = parser.getText();
          } else if (text == 'Sector') {
            Sector = parser.getText();
          } else if (text == 'Made Criteria') {
            MadeCriteria = parser.getText();
          } else if (text == 'Prospect Source') {
            ProspectSource = parser.getText();
          } else if (text == 'Marketing Channel') {
            MarketingChannel = parser.getText();
          } else if (text == 'Appointment Type') {
            AppointmentType = parser.getText();
          } else if (text == '#FTE') {
            FTE = parser.getText();
          } else if (text == 'Booking Length') {
            BookingLength = parser.getIntegerValue();
          } else if (text == 'BDM') {
            BDM = arrayOfBDM(parser);
          } else if (text == 'Request Id') {
            RequestId = parser.getText();
          }  
                    else {
            System.debug(LoggingLevel.WARN, 'BookYourAppointmentJSON2Apex consuming unrecognized property: '+text);
            consumeObject(parser);
          }
        }
      }
    }
  }
  
  public class BDM {
    public String BDMId {get;set;} 
    public String BDMName {get;set;} 
    public List<AvailableTimeSlots> AvailableTimeSlots {get;set;} 

    public BDM(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'BDM Id') {
              BDMId = parser.getText();
            } else if (text == 'BDM Name') {
              BDMName = parser.getText();
            } else if (text == 'Available Time Slots') {
              AvailableTimeSlots = arrayOfAvailableTimeSlots(parser);
            } else {
              System.debug(LoggingLevel.WARN, 'BDM consuming unrecognized property: '+text);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
    
  public static BDMAllocationJSON2Apex parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new BDMAllocationJSON2Apex(parser);
  }
  
  public static void consumeObject(System.JSONParser parser) {
    Integer depth = 0;
    do {
      System.JSONToken curr = parser.getCurrentToken();
      if (curr == System.JSONToken.START_OBJECT || 
        curr == System.JSONToken.START_ARRAY) {
        depth++;
      } else if (curr == System.JSONToken.END_OBJECT ||
        curr == System.JSONToken.END_ARRAY) {
        depth--;
      }
    } while (depth > 0 && parser.nextToken() != null);
  }

    private static List<BDM> arrayOfBDM(System.JSONParser p) {
        List<BDM> res = new List<BDM>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new BDM(p));
        }
        return res;
    }

    private static List<AvailableTimeSlots> arrayOfAvailableTimeSlots(System.JSONParser p) {
        List<AvailableTimeSlots> res = new List<AvailableTimeSlots>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AvailableTimeSlots(p));
        }
        return res;
    }
}