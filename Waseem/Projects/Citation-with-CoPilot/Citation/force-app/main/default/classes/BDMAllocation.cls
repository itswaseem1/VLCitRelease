public class BDMAllocation {              
    /*public class MissingFieldsinfo{
        public String Postalcode {set;get;}
        public String LeadSource {set;get;}
        public String Company {set;get;}
        public String CitationSector {set;get;}
        public String MADECriteria {set;get;}
        public String MarketingChannel {set;get;}
        public String AppointmentType {set;get;}
        public String FT_Employees {set;get;}
    }*/
    
    public class confirmbookingparam{
        @AuraEnabled public string BDMId{set; get;}
        @AuraEnabled public string BDMName{set; get;}
        @AuraEnabled public string Day{set; get;}
        @AuraEnabled public string Date_Z{set; get;}
        @AuraEnabled public string Slot_End_Time{set; get;}
        @AuraEnabled public string Slot_Start_Time{set; get;}
        @AuraEnabled public Integer Score{set; get;}
    }
    
    @AuraEnabled
    public static string getAvailability(Id recId,String CurrentObject){
    String getAvailabiltyEndpoint = System.Label.BDMGetAvailabilityEndpoint;
    String authtoken = system.Label.BDMAuthorizationToken;
        Integer count=0;
        List<String> errorfields = new List<String>();
        Map<String, String> mp = new Map<String,string>();
        String tempstr;
        String S2;
        string s3 = '{'+'"body":'+'"';
        string prospecterrorstatus='{'+'"prospecterrormessage":'+'"';
        String res;
        string jbody;
        String sbody;
        if(CurrentObject=='Lead'){
        //MissingFieldsinfo m = new MissingFieldsinfo();
        Lead l = [select Id, PostalCode, OwnerId, Owner.name, Compliance_Referral_Type__c, LeadSource, Company, CitationSector__c, MADE_Criteria__c, Appointment_Type__c, Total_Employees__c  from Lead where Id=: recId];
        sbody = '{' +'"Opportunity Id":';   
        sbody = sbody+'"'+l.Id+'"'+','+'"Client Name":'+'"'+l.Company+'"'+','+'"Client PostCode":'+'"'+l.PostalCode+'"'+',';
        sbody = sbody+'"Sector":'+'"'+l.CitationSector__c+'"'+','+'"Made Criteria":'+'"'+l.MADE_Criteria__c+'"'+',';
        sbody = sbody+'"Prospect Source":'+'"'+l.LeadSource+'"'+','+'"Compliance Referral Type":'+'"'+l.Compliance_Referral_Type__c+'"'+',';
        sbody = sbody+'"Appointment Type":'+'"'+l.Appointment_Type__c+'"'+','+'"#FTE":'+'"'+l.Total_Employees__c+'"'+',';
        sbody = sbody+'"Named BDM Id":'+'"'+l.OwnerId+'"'+','+'"Named BDM Name":'+'"'+l.Owner.name+'"'+'}';
        system.debug('sbody'+sbody);
        if(l.LeadSource!=null && l.PostalCode!=null && l.Company!=null && l.CitationSector__c!=null && l.MADE_Criteria__c!=null &&l.Appointment_Type__c!=null && l.Total_Employees__c!=null){
            /*When Prospect Source is any of these 
            	"Ref_Employee, Ref_Employee_&_Client, Seminar, BDM_BDC_SelfGen, Xact Partner, BDMBDC_SelfGen_Ref, 
            	SEM_TunbridgeWellsNov19_Company, SEM_SPICAGMSep19_Partner, SEM_SMASManchesterOct19_Company, 
            	SEM_RickmansworthJuly18_Company, SEM_LiverpoolApril18_Company, SEM_CwmbranJuly18_Company, 
            	SEM_BournemouthNov19_Company, BDM_SelfGen_Ref" set prospecterrorstatus to true so that 
				error message is displayed instead of a blank screen*/
            String prospectSourceforBookingBDMAppointment=System.label.ProspectSourceforBookingBDMAppointment;
            String irrelevantBDM=System.label.Irrelevant_BDM;
            List<String> prospectSourceValues=prospectSourceforBookingBDMAppointment.split(',');
            List<String> irrelevantBDMsList=irrelevantBDM.split(',');
            if(prospectSourceValues.contains(l.LeadSource) && irrelevantBDMsList.contains(l.Owner.name)){
                if((l.LeadSource!='Ref_Employee' && l.LeadSource!='Ref_Employee_&_Client') ||((l.LeadSource=='Ref_Employee' || l.LeadSource=='Ref_Employee_&_Client') && (l.Compliance_Referral_Type__c!='New client'))){
                prospecterrorstatus=prospecterrorstatus+'true';
                prospecterrorstatus = prospecterrorstatus+'"'+'}';
            	S2 = JSON.serialize(prospecterrorstatus);
				count=count+2;
            }
            else{
                count=count+1;
            }
        }
            else{
                count=count+1;
            }
        }
        if(l.PostalCode==null){
            mp.put('Postal Code','Postal Code;');
        }
        if(l.LeadSource==null){
            mp.put('Prospect Source','Prospect Source;');
        }
        if(String.isEmpty(l.Company)||l.Company==null||String.isBlank(l.Company)){
            mp.put('Company','Company;');
        } 
        if(l.CitationSector__c==null){
            mp.put('Citation Sector','Citation Sector;');
        }
        if(l.MADE_Criteria__c==null){
            mp.put('MADE Criteria','MADE Criteria;');
        }
        if(l.Appointment_Type__c==null){
            mp.put('Appointment Type','Appointment Type;');
        }
        if(l.Total_Employees__c==null){
            mp.put('FT Employees','FT Employees;');
        }
        errorfields = mp.values();
        }
        else if(CurrentObject=='Opportunity'){
            Opportunity opprec = [Select Id,Account.Name,Compliance_Referral_Type__c,OwnerId,Owner.name,PostCode__c,MADE_Criteria__c,Total_Employees__c,Account_Sector__c,Appointment_Type__c,LeadSource From Opportunity where Id=: recId];
            sbody = '{' +'"Opportunity Id":';   
            sbody = sbody+'"'+opprec.Id+'"'+','+'"Client Name":'+'"'+opprec.Account.Name+'"'+','+'"Client PostCode":'+'"'+opprec.PostCode__c+'"'+',';
            sbody = sbody+'"Sector":'+'"'+opprec.Account_Sector__c+'"'+','+'"Made Criteria":'+'"'+opprec.MADE_Criteria__c+'"'+',';
            sbody = sbody+'"Prospect Source":'+'"'+opprec.LeadSource+'"'+','+'"Compliance Referral Type":'+'"'+opprec.Compliance_Referral_Type__c+'"'+',';
            sbody = sbody+'"Appointment Type":'+'"'+opprec.Appointment_Type__c+'"'+','+'"#FTE":'+'"'+opprec.Total_Employees__c+'"'+',';
            sbody = sbody+'"Named BDM Id":'+'"'+opprec.OwnerId+'"'+','+'"Named BDM Name":'+'"'+opprec.Owner.name+'"'+'}';
            if(opprec.PostCode__c!=null && opprec.MADE_Criteria__c!=null && opprec.Total_Employees__c!=null && opprec.Account_Sector__c!=null && opprec.Appointment_Type__c!=null && opprec.LeadSource!=null){
               count=1; 
            }
        }
        if(count==1){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(getAvailabiltyEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authtoken);    
            request.setTimeout(20000);
            request.setBody(sbody);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() <299) {
                System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
                res=response.getBody();
                system.debug('res'+res);
                BDMAllocationJSON2Apex jsonApex = BDMAllocationJSON2Apex.parse(res);
                system.debug('japex'+jsonApex.BDM[0]);
                //jsonApex.BDM = sortAppointments(jsonApex.BDM);
                S2 = JSON.serialize(jsonApex);
                system.debug('s2'+S2);
            } else {
                system.debug('code'+response.getStatusCode());
                System.debug(response.getBody());
            }
        }
        else if(count==0){
            system.debug('values'+JSON.serialize(mp.keySet()));
            if(errorfields.size()>0){
                for(Integer i=0;i<errorfields.size();i++){
                   //s3=s3+errorfields[i]+','; 
                   s3=s3+errorfields[i]; 
                }
            }
            s3 = s3+'"'+'}';
            system.debug('s3'+s3);
            S2 = JSON.serialize(s3);
            system.debug('S2'+S2);
        } 
        return S2;
    }
    
    @AuraEnabled
    public static string ConfirmBooking(Id OpportunityId, String RequestId, confirmbookingparam cp, string Actualstarttime, string ActualEndtime, Integer appointmentduration,String CurrentObject){
        string confirmresult;
        string actdate = String.valueOf(cp.Date_Z);
    List<string> s2 = actdate.split('-');
    List<string> s3 = Actualstarttime.split(':');
        Lead l1;
        Opportunity opp;
        if(CurrentObject=='Lead'){
        	l1 = [select Id, OwnerId, Status from Lead where Id=: OpportunityId];
        }
        else if(CurrentObject=='Opportunity'){
            opp=[select Id,OwnerId,Contact__c From Opportunity where Id=: OpportunityId];
        }
        User u = [select Id, Name from User where Id=:cp.BDMId limit 1];

        Event e = new Event();
        e.Subject = '1st Meeting - Confirmed';
        if(CurrentObject=='Lead'){
          e.whoId = OpportunityId;   
        }
        else if(CurrentObject=='Opportunity'){
           e.whoId = opp.Contact__c; 
            e.WhatId = OpportunityId;
        }
        e.OwnerId = cp.BDMId;
        e.CurrencyIsoCode = 'GBP';
        e.DurationInMinutes = appointmentduration;
        e.ActivityDateTime = DateTime.newInstance(Integer.valueOf(s2[0]), Integer.valueOf(s2[1]), Integer.valueOf(s2[2]) , Integer.valueOf(s3[0]), Integer.valueOf(s3[1]), 00);
        e.Type='1st Visit'; 
        try{
              insert e;
                system.debug('activty date time'+e.ActivityDateTime);
                system.debug('subject'+e.Subject);
          }
          catch(Exception evt){
              system.debug('error'+evt.getMessage());
          }
          system.debug('eID'+e.Id);
            string reqbody = '{' +'"Request Id":';
            reqbody = reqbody+'"'+RequestId+'"'+','+'"BDM Id":'+'"'+cp.BDMId+'"'+','+'"BDM Name":'+'"'+cp.BDMName+'"'+','; 
            reqbody = reqbody + '"Score":'+'"'+cp.Score+'"'+','+'"Day":'+'"'+cp.Day+'"'+','; 
            reqbody = reqbody + '"Date":'+'"'+cp.Date_Z+'"'+','+'"Slot Start Time":'+'"'+cp.Slot_Start_Time+'"'+','; 
            reqbody = reqbody + '"Slot End Time":'+'"'+cp.Slot_End_Time+'"'+','+'"Actual Booking Start Time":'+'"'+Actualstarttime+'"'+','; 
            reqbody = reqbody + '"Actual Booking End Time":'+'"'+ActualEndtime+'"'+'}';
            system.debug('reqbody'+reqbody);          
          if(e.Id!=null){
              try{
                  if(CurrentObject=='Lead'){
                      l1.OwnerId = u.Id;
                      update(l1);
                  }
                  else if(CurrentObject=='Opportunity'){
                      opp.OwnerId = u.Id;
                      update(opp);
                  }  
              }                
              catch(Exception et){
                  system.debug('et'+et.getMessage());
              }
                confirmresult='{'+'"'+'status'+'":'+'200,'+'"'+'body'+'":'+'"'+'Event Created Sucessfully for BDM'+' '+u.Name+'"'+'}';
              makecallout(reqbody);
          }             
    system.debug('string confirmresult'+confirmresult);        
        return confirmresult;
    }
    
    @future(callout=true)
    public static void makecallout(String rbody){
         String ConfirmAvailabilityEndpoint = System.Label.BDMConfirmAvailabilityEndpoint;
    String authtoken = system.Label.BDMAuthorizationToken;
        system.debug('inside make'+rbody);
        string result;
          Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ConfirmAvailabilityEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authtoken);            
            request.setBody(rbody);
            HttpResponse response = http.send(request);
            system.debug('confirmation response'+response.getStatusCode());
            if(response.getStatusCode() <299){
                result = response.getBody(); 
                system.debug('confirmresult'+result);
                system.debug('code'+response.getStatusCode());
                system.debug('body'+response.getBody());
            }  
    }
}