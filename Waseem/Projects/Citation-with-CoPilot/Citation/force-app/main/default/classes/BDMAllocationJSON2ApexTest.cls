@IsTest
public class BDMAllocationJSON2ApexTest {
  
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json = '{'+
    '    \"Opportunity Id\": \"0064G000014di0bQAA\",'+
    '    \"Client Name\": \"ABC Customer\",'+
    '    \"Client PostCode\": \"DY6 7UT\",'+
    '    \"Client Region\": \"West Midlands\",'+
    '    \"Sector\": \"CARE\",'+
    '    \"Made Criteria\": \"Inbound 1\",'+
    '    \"Prospect Source\": \"PPC\",'+
    '    \"Marketing Channel\": \"PPC\",'+
    '    \"Appointment Type\": \"Combined\",'+
    '    \"#FTE\": \"120\",'+
    '    \"Booking Length\": 90,'+
    '    \"BDM\": ['+
    '        {'+
    '            \"BDM Id\": \"0054G00000BIy9sQAD\",'+
    '            \"BDM Name\": \"Darren Spry\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 73,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 65,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 61,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D00000036t79IAA\",'+
    '            \"BDM Name\": \"James O\'Hare\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 87,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"15:00:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 82,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 70,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D000000377NdIAI\",'+
    '            \"BDM Name\": \"Mark Kelsall\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 70,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 66,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"14:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 66,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"16:00:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 62,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D000000377NeIAI\",'+
    '            \"BDM Name\": \"Trevor Kerins\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 73,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 66,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 61,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D000000377NfIAI\",'+
    '            \"BDM Name\": \"Alastair Stevens\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 79,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 73,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 67,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D000000377NhIAI\",'+
    '            \"BDM Name\": \"Justin McCormick\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 80,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 72,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 69,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D00000038lvnIAA\",'+
    '            \"BDM Name\": \"William McFaulds\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 75,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 69,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 63,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D0000004HVifIAG\",'+
    '            \"BDM Name\": \"Dominic Miller\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 100,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 93,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 84,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D00000054e0UIAQ\",'+
    '            \"BDM Name\": \"Bill Bourne\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 91,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 85,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 80,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D00000054qKRIAY\",'+
    '            \"BDM Name\": \"Gary Smith\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 77,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 70,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 65,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D0000005v0zxIAA\",'+
    '            \"BDM Name\": \"Tim Kirk\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 68,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 63,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 61,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D0000007WJVaIAO\",'+
    '            \"BDM Name\": \"Alan Butler\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 83,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 75,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 70,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D0000008g0LBIAY\",'+
    '            \"BDM Name\": \"Colin Camburn\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 73,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 66,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 60,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        },'+
    '        {'+
    '            \"BDM Id\": \"005D0000008uVHXIA2\",'+
    '            \"BDM Name\": \"Brian Galloway\",'+
    '            \"Available Time Slots\": ['+
    '                {'+
    '                    \"Score\": 78,'+
    '                    \"Day\": \"Tuesday\",'+
    '                    \"Date\": \"2021-05-18\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 71,'+
    '                    \"Day\": \"Wednesday\",'+
    '                    \"Date\": \"2021-05-19\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                },'+
    '                {'+
    '                    \"Score\": 68,'+
    '                    \"Day\": \"Monday\",'+
    '                    \"Date\": \"2021-05-17\",'+
    '                    \"Slot_Start_Time\": \"09:30:00\",'+
    '                    \"Slot_End_Time\": \"17:30:00\"'+
    '                }'+
    '            ]'+
    '        }'+
    '    ]'+
    '}';
    BDMAllocationJSON2Apex r = BDMAllocationJSON2Apex.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    BDMAllocationJSON2Apex.AvailableTimeSlots objAvailableTimeSlots = new BDMAllocationJSON2Apex.AvailableTimeSlots(System.JSON.createParser(json));
    System.assert(objAvailableTimeSlots != null);
    System.assert(objAvailableTimeSlots.Score == null);
    System.assert(objAvailableTimeSlots.Day == null);
    System.assert(objAvailableTimeSlots.Date_Z == null);
    System.assert(objAvailableTimeSlots.Slot_Start_Time == null);
    System.assert(objAvailableTimeSlots.Slot_End_Time == null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    BDMAllocationJSON2Apex objBookYourAppointmentJSON2Apex = new BDMAllocationJSON2Apex(System.JSON.createParser(json));
    System.assert(objBookYourAppointmentJSON2Apex != null);
    System.assert(objBookYourAppointmentJSON2Apex.OpportunityId == null);
    System.assert(objBookYourAppointmentJSON2Apex.ClientName == null);
    System.assert(objBookYourAppointmentJSON2Apex.ClientPostCode == null);
    System.assert(objBookYourAppointmentJSON2Apex.ClientRegion == null);
    System.assert(objBookYourAppointmentJSON2Apex.Sector == null);
    System.assert(objBookYourAppointmentJSON2Apex.MadeCriteria == null);
    System.assert(objBookYourAppointmentJSON2Apex.ProspectSource == null);
    System.assert(objBookYourAppointmentJSON2Apex.MarketingChannel == null);
    System.assert(objBookYourAppointmentJSON2Apex.AppointmentType == null);
    System.assert(objBookYourAppointmentJSON2Apex.FTE == null);
    System.assert(objBookYourAppointmentJSON2Apex.BookingLength == null);
    System.assert(objBookYourAppointmentJSON2Apex.BDM == null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    BDMAllocationJSON2Apex.BDM objBDM = new BDMAllocationJSON2Apex.BDM(System.JSON.createParser(json));
    System.assert(objBDM != null);
    System.assert(objBDM.BDMId == null);
    System.assert(objBDM.BDMName == null);
    System.assert(objBDM.AvailableTimeSlots == null);
  }
}