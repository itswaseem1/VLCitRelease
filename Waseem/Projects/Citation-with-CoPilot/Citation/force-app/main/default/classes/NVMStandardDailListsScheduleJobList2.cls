global class NVMStandardDailListsScheduleJobList2 implements Database.Batchable<SObject>,Database.Stateful{
    
    private String query;
    Integer totalNotConvertedLeads                      = 0;
    Integer totalLeadsMetCriteria                       = 0;
    List<Lead> filteredLeadList                         = new List<Lead>();
    public Map<Id,Lead> finalUpdateLeadList             = new Map<Id,Lead>();
    Map<Id,Lead> nullList                               = new Map<Id,Lead>();
    Map<Id,Decimal> listIdList                          = new Map<Id,Decimal>();
    List<Job_Execution_Status_Update__mdt> recordStatus = new List<Job_Execution_Status_Update__mdt>();
    List<Automation_Configuration__c> sectorList        = new List<Automation_Configuration__c>();
    Map<String,Automation_Configuration__c> sourceMap   = new Map<String,Automation_Configuration__c>();
    Map<String,Automation_Configuration__c> postcodeMap = new Map<String,Automation_Configuration__c>();
    Map<decimal,Automation_Configuration__c> SICCd3Map  = new Map<decimal,Automation_Configuration__c>();
    Map<String,Decimal> bdmMap                          = new Map<String,Decimal>();
    map<string,id> automationBDMType                    = new map<string,id>();
    static final Id sourceRecTypeId                     = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Source Exclusion').getRecordTypeId();
    static final Id sectorRecTypeId                     = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Sector Exclusion').getRecordTypeId();
    static final Id outcodeRecTypeId                    = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Outcode Exclusion').getRecordTypeId();
    static final Id bdmlimitsRecTypeId                  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL BDM Limits').getRecordTypeId();
    static final Id SIC2007_Code3ExcID                  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL SIC2007 Code3 Exclusion').getRecordTypeId();
    map<string,Automation_Configuration__c> MACList     = new map<string,Automation_Configuration__c>(); 
    Map<String,List<id>> bdmLeads                       = new Map<String,List<id>>();  
    List<String> toAddresses                            = new List<String>{'srikanthragi@itation.co.uk'};  
    public integer BfInt = 0;
    public integer AfInt = 0;
    public id leadidd;
    public list<id> seleLead                            = new list<id>();
    public map<String,List<id>> mappbdm = new map<String,List<id>>();
    public string currentjName; 
    public NVMStandardDailListsScheduleJobList2(String jobName){
        currentjName = jobName;
        query = 'SELECT Id,Name,List_Type__c,CitationSector__c,Data_Supplier__c,SIC2007_Code3__c,List_ID__c,NVMConnect__NextContactTime__c,Basic_Crit__c,FTE_Crit__c,Source__c,OutboundCallCount__c,OwnerId,Owner.Name,PostalCode,LastOutboundCall__c,CreatedDate FROM Lead WHERE IsConverted=false and List_Type__c =: currentjName ORDER BY Owner.Name,LastOutboundCall__c ASC NULLS FIRST, CreatedDate DESC NULLS FIRST';
        system.debug(query);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        for(Automation_Configuration__c ac : [SELECT Id,RecordTypeId,BDM__c,Citation_Sector__c,Data_Supplier__c,FT_Employees_Higher__c,FT_Employees_Lower__c,List_Type__c,Maximum_Prospects__c,Outcode__c,Release_Field__c,Release_Threshold__c,Release_Threshold_Operator__c,SIC2007_Code__c,SIC2007_Code3__c,Source__c FROM Automation_Configuration__c]){
            if(ac.RecordTypeId==sourceRecTypeId){
                sourceMap.put(ac.Source__c,ac);
            }
            if(ac.RecordTypeId == SIC2007_Code3ExcID){
                SICCd3Map.put(ac.SIC2007_Code3__c,ac);
            }
            if(ac.RecordTypeId==sectorRecTypeId){
                sectorList.add(ac);
            }
            if(ac.RecordTypeId==outcodeRecTypeId){
                postcodeMap.put(ac.Outcode__c,ac);
            }
            if(ac.RecordTypeId==bdmlimitsRecTypeId){
                bdmMap.put(ac.BDM__c+' : '+ac.List_Type__c,ac.Maximum_Prospects__c);
                automationBDMType.put(ac.BDM__c+' : '+ac.List_Type__c,ac.id);
            }

        }
        for(Job_Execution_Status_Update__mdt jes : [SELECT Id,MasterLabel,Result_Message_1__c,Result_Message_2__c,Result_Message_3__c,Result_Message_4__c FROM Job_Execution_Status_Update__mdt]){
            recordStatus.add(jes);
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope){
        try{
            Map<Id,Lead> originalLeadList                       = new Map<Id,Lead>();
            Map<Id,Boolean> firstExcl                           = new Map<Id,Boolean>();
            Map<Id,Boolean> sourceExcl                          = new Map<Id,Boolean>();
            Map<Id,Boolean> SICCd3Excl                          = new Map<Id,Boolean>();
            Map<Id,Boolean> sectorExcl                          = new Map<Id,Boolean>();
            Map<Id,Boolean> postcodeExcl                        = new Map<Id,Boolean>();
            //Updation to null
            for(Lead l : scope){
                totalNotConvertedLeads+=1;
                originalLeadList.put(l.Id,l);
            }
            system.debug('postcodeMap--'+postcodeMap);
            for(Lead l : scope){
                system.debug('Lead l--'+l);
                //Inclusion Basic Crit, FTE_Crit and Next Contact Time
                leadidd = l.id;
                //OutCode contains check
                for(String s : postcodeMap.keySet()){
                    system.debug('String s--'+s);
                    system.debug('String v--'+postcodeMap.get(s));
                    if(l.PostalCode!=null && l.PostalCode.contains(s)){
                        if(postcodeMap.get(s).Release_field__c!=null && postcodeMap.get(s).Release_field__c.equals('ALL')){
                            postcodeExcl.put(l.Id,false);
                        }else if(!postcodeMap.get(s).Release_field__c.equals('ALL') && postcodeMap.get(s).Release_Threshold_Operator__c!=null && postcodeMap.get(s).Release_Threshold__c!=null && l.OutboundCallCount__c!=null){
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='=' && l.OutboundCallCount__c==Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='<>' && l.OutboundCallCount__c<>Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='<' && l.OutboundCallCount__c<Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='>' && l.OutboundCallCount__c>Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='<=' && l.OutboundCallCount__c<=Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                            if(postcodeMap.get(s).Release_Threshold_Operator__c=='>=' && l.OutboundCallCount__c>=Decimal.valueOf(postcodeMap.get(s).Release_Threshold__c)){
                                postcodeExcl.put(l.Id,false);
                                continue;
                            }
                        }
                    }              
                }
                //Source contains check
                for(String s : sourceMap.keySet()){
                    if(l.Source__c!=null && l.Source__c.containsIgnoreCase(s)){
                        if(sourceMap.get(s).Release_field__c!=null && sourceMap.get(s).Release_field__c.equals('ALL')){
                            sourceExcl.put(l.Id,false);
                        }else if(!sourceMap.get(s).Release_field__c.equals('ALL') && sourceMap.get(s).Release_Threshold_Operator__c!=null && sourceMap.get(s).Release_Threshold__c!=null && l.OutboundCallCount__c!=null){
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='=' && l.OutboundCallCount__c==Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='<>' && l.OutboundCallCount__c<>Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='<' && l.OutboundCallCount__c<Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='>' && l.OutboundCallCount__c>Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='<=' && l.OutboundCallCount__c<=Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                            if(sourceMap.get(s).Release_Threshold_Operator__c=='>=' && l.OutboundCallCount__c>=Decimal.valueOf(sourceMap.get(s).Release_Threshold__c)){
                                sourceExcl.put(l.Id,false);
                                continue;
                            }
                        }
                    }
                }

                // SIC2007-Code3 contains check
                    
                    if(l.SIC2007_Code3__c!=null && SICCd3Map.containsKey(l.SIC2007_Code3__c.setScale(0))){
                        decimal ds = l.SIC2007_Code3__c.setScale(0);
                        if(SICCd3Map.get(ds).Release_field__c!=null && SICCd3Map.get(ds).Release_field__c.equals('ALL')){
                            SICCd3Excl.put(l.Id,false);
                        }
                    }
                

                    //Sector and Data Supplier contains check
                for(Automation_Configuration__c s : sectorList){
                    if(s.Citation_Sector__c != null && s.Data_Supplier__c!= null && s.Release_field__c!=null){
                        if(l.CitationSector__c != null && s.Data_Supplier__c.equals('ALL') && l.CitationSector__c.equals(s.Citation_Sector__c) && s.Release_field__c.equals('ALL')){
                            system.debug('Im here 1');
                            sectorExcl.put(l.Id,false);
                        }
                        else if(l.Data_Supplier__c != null && l.CitationSector__c != null && l.Data_Supplier__c.containsIgnoreCase(s.Data_Supplier__c) && l.CitationSector__c.equals(s.Citation_Sector__c) && s.Release_field__c.equals('ALL')){
                            system.debug('Im here 0+1');
                            sectorExcl.put(l.Id,false);
                        }
                        else if(l.Data_Supplier__c != null && l.Data_Supplier__c.containsIgnoreCase(s.Data_Supplier__c) && s.Citation_Sector__c.equals('ALL') && s.Release_field__c.equals('ALL')){
                            system.debug('Im here 0+1');
                            sectorExcl.put(l.Id,false);
                        }
                        else if(s.Data_Supplier__c != null && s.Data_Supplier__c.equals('ALL') && s.Citation_Sector__c.equals('ALL') && s.Release_field__c.equals('ALL')){
                            system.debug('Im here 0+1');
                            sectorExcl.put(l.Id,false);
                        }
                        else if(l.OutboundCallCount__c!=null && s.Release_Threshold_Operator__c!=null && s.Release_Threshold__c!=null && ((l.Data_Supplier__c != null && l.Data_Supplier__c.containsIgnoreCase(s.Data_Supplier__c)) || s.Data_Supplier__c.equals('ALL')) && ((l.CitationSector__c !=null && l.CitationSector__c.equals(s.Citation_Sector__c)) || s.Citation_Sector__c.equals('ALL'))){
                            system.debug('Im here for a reason');
                            if(s.Release_Threshold_Operator__c=='=' && l.OutboundCallCount__c==Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 2');
                                continue;
                            }
                            if(s.Release_Threshold_Operator__c=='<>' && l.OutboundCallCount__c<>Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 3');
                                continue;
                            }
                            if(s.Release_Threshold_Operator__c=='<' && l.OutboundCallCount__c<Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 4');
                                continue;
                            }
                            if(s.Release_Threshold_Operator__c=='>' && l.OutboundCallCount__c>Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 5');
                                continue;
                            }
                            if(s.Release_Threshold_Operator__c=='<=' && l.OutboundCallCount__c<=Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 6');
                                continue;
                            }
                            if(s.Release_Threshold_Operator__c=='>=' && l.OutboundCallCount__c>=Decimal.valueOf(s.Release_Threshold__c)){
                                sectorExcl.put(l.Id,false);
                                system.debug('Im here 7');
                                continue;
                            }
                        }
                    }
                }
                system.debug('sectorExcl+++'+sectorExcl);
                bfInt++;
                
                if(((l.NVMConnect__NextContactTime__c<Date.today() || l.NVMConnect__NextContactTime__c==null) && l.Basic_Crit__c==true && l.FTE_Crit__c==true) && (!sourceExcl.containsKey(l.Id) && !sectorExcl.containsKey(l.Id) && !postcodeExcl.containsKey(l.Id) && !SICCd3Excl.containsKey(l.id))){
                    AfInt++;
                    seleLead.add(l.id);
                                       
                }
                
            }
            //Total Exclusion List
            /*for(Lead l : originalLeadList.values()){
                if(firstExcl.containsKey(l.Id) && (!sourceExcl.containsKey(l.Id) && !sectorExcl.containsKey(l.Id) && !postcodeExcl.containsKey(l.Id))){
                    if(bdmMap.containsKey(l.Owner.Name+' : '+l.List_Type__c)){
                        filteredLeadList.add(l);
                    }
                }
            }*/
            
            
        }//try end
        catch(Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setsubject('If any exceptions ');
            mail.SetPlainTextbody(  'Errors '                                      +     leadidd        + '\n' +e.getLineNumber()+' '+e.getMessage());
            mail.setToAddresses(toAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            
            System.debug(' NVMStandardDailListsScheduleJob Exception Message :::'+e.getMessage());
            System.debug('NVMStandardDailListsScheduleJob Exception Line No :::'+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext bc){
        system.debug('bfInt+++AfInt'+BfInt+' - '+AfInt);
        //Ordering the List
        map<id,string> LeadBDMMap = new map<id,string>();
        integer BDMselected = 0;
        integer BDMDillable = 0;
        system.debug('filteredLeadList+++dig'+filteredLeadList.size());
        system.debug('bdmLeads+++'+bdmLeads.size());
        list<lead> sortedLead = [SELECT Id,List_Type__c,Owner.Name,LastOutboundCall__c,CreatedDate FROM Lead WHERE IsConverted=false and id In:seleLead ORDER BY Owner.Name,LastOutboundCall__c ASC NULLS FIRST, CreatedDate DESC NULLS FIRST];
        for(lead l: sortedLead){
            if(bdmMap.containsKey(l.Owner.Name+' : '+l.List_Type__c)){
                            if(bdmLeads.containsKey(l.Owner.Name+' : '+l.List_Type__c)){
                                bdmLeads.get(l.Owner.Name+' : '+l.List_Type__c).add(l.id);
                            }else{
                                List<id> leadIdList = new List<id>();
                                leadIdList.add(l.id);
                                bdmLeads.put(l.Owner.Name+' : '+l.List_Type__c,leadIdList);
                            }
            }
        }    
        //Assigning ListID
        for(String s : bdmLeads.keySet()){
            List<id> lRec = bdmLeads.get(s);
            Automation_Configuration__c AcTemp = new Automation_Configuration__c();
                for(Integer i=0;i<lRec.size() && i+1<=bdmMap.get(s);i++){
                    totalLeadsMetCriteria+=1;
                    lead ldsf = new lead();
                    BDMselected+=1;
                    ldsf.List_ID__c = i+1;
                    ldsf.NVM_DL__c = recordStatus[0].Result_Message_1__c;
                    ldsf.id = lRec[i];
                    //finalUpdateLeadList.put(lRec[i].Id,lRec[i]);
                    LeadBDMMap.put(ldsf.id,s);
                    listIdList.put(ldsf.Id,ldsf.List_ID__c);
                }
                BDMDillable = lRec.size();
                AcTemp.id = automationBDMType.get(s);
                AcTemp.selected__c = BDMselected;
                AcTemp.Diallable__c = BDMDillable;
                BDMDillable = 0;
                BDMselected = 0;
                MACList.put(s,AcTemp);
        }
        system.debug('listIdList'+listIdList.size()+'--'+currentjName);
        Database.executeBatch(new NVMStandardDailListsUpdation(listIdList, MACList, LeadBDMMap, recordStatus, totalNotConvertedLeads, totalLeadsMetCriteria,currentjName), 50);
        if(Test.isRunningTest()){
            Account acc = new Account();
            acc.Name='test';
            acc.AccountSource ='Partnership';
            acc.Website ='www.google.com';
            acc.Type ='Client';
            acc.PartnerType__c ='Partner';
            acc.Is_Active_Partner__c = true;
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Accountant_Street__c ='Stree';
            acc.BillingCity ='City';
            acc.BillingCountry ='Countr';
            acc.BillingStreet ='BillStree';
            acc.BillingState ='State';
            acc.Account_Number__c ='12344';
            acc.Account_Holder_Name_1__c ='Holder1';
            acc.Account_Holder_Name_2__c ='Holder2';
            acc.Accountant_Company__c ='Comp';
            acc.Accountant_County__c ='Bangla';
            acc.Total_H_S_Member_Atlas_Access_Units__c =10;
            acc.Total_HR_Member_Atlas_Access_Units__c = 10;
            acc.Assigned_H_S_Member_Atlas_Access_Units__c =2;
            acc.Assigned_HR_Member_Atlas_Access_Units__c =5;
            acc.Trading_As_Name__c ='Trading';
            acc.A_Checkbox__c = true;
            acc.Site ='12345';
        }
    }

}