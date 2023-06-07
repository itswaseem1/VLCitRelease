global class SelfServeReportResultsUpdateOpp implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String                             query;
    public list<id>                            recordIds {get;set;}
    public map<id,list<DML_Outcome__c>>        ACist;
    List<String>                               toAddresses              = new list<string>();
    string                                     reportName               = '';
    integer                                    recProcessed             = 0;
    boolean                                    stpr                     = false;
    Integer                                    totalLeadsUpdated        = 0;
    public string                              reportId;
    map<id,string>                             mapOpIdDuplicat          = new map<id,string>();
    map<id,string>                             mapfinalErr              = new map<id,string>();
    List<Database.SaveResult>                  dbList                   = new List<Database.SaveResult>();
    map<string,list<string>>                   mapOutcome               = new map<string,list<string>> ();
    map<id,lead>                               mapLdPros                = new map<id,lead>();
    map<id,lead>                               mapLeadList              = new map<id,lead>();     
    string                                     oppQuery                 = '';
    String                                     accQuery                 = '';
    String                                     contQuery                = '';
    Integer                                    noOppInReport            = 0;
    Integer                                    noProspectsSelected      = 0;
    Integer                                    noContCantCreated        = 0;
    Integer                                    noProspecsCreated        = 0;    
    Boolean                                    dpRule                   = true; 
    public SelfServeReportResultsUpdateOpp(list<id> recordId,string objname,map<id,list<DML_Outcome__c>> acList,string rpna,integer totr,string rpid,boolean dupRule){
        dpRule = dupRule;
        if(!dpRule){
            id UserId =(Id)UserInfo.getUserId();
            User                        toUp = new User();
            toUp.id = UserId;
            toUp.Run_Duplicate_Rules__c = false;
            update toUp;
        }
        system.debug('Al records'+recordIds);
        if(totr != null && totr != 0){
            totalLeadsUpdated = totr;
        }
        reportName = rpna;
        reportId = rpid;
        ACist = acList;
        list<Automation_Configuration__c> acLstQ= [select id,Distribution_List__c from Automation_Configuration__c where id In: ACist.keyset()];
        toAddresses = ((String)acLstQ[0].Distribution_List__c).split(',') ;
        system.debug('ACist Records'+ACist);
        recordIds = recordId;
        query = 'select id,Account.Open_Core_Opportunities__c,Account.id,BDC_Manager__c, (SELECT ContactId,Id,contact.Email_Domain__c,IsPrimary';
        for(list<DML_Outcome__c> dll:ACist.values()) {
            for(DML_Outcome__c dla: dll){
                if(dla.outcome__c != '' && dla.Field_API_Name__c != null){
                    map<string,list<string>>            temMapOutCome   = new map<string,list<string>> ();
                    temMapOutCome  = AutomationConfigurationDMLQSplits.closedLostOutSplit(dla.outcome__c);
                    mapOutcome.putall(temMapOutCome);
                    for(string outc: temMapOutCome.keyset()){
                        list<string>        outCValues  = temMapOutCome.get(outc);
                        if(outc.contains('Account') && !(query.containsIgnoreCase(outCValues[0]))){
                            accQuery    += ', ' + outCValues[0];
                        }

                        if(outc.contains('Contact')){
                            contQuery   +=', ' + outCValues[0];
                        }

                        if(outc.contains('Opportunity')){
                            oppQuery    += ', ' + outCValues[0];
                        }
                    }
                   
                }
            }
        }
        
        //oppQuery += oppQuery+ ' from lead where id in:recordIds';   
        
        /*if(objname == 'Lead'){
            for(list<DML_Outcome__c> dll:ACist.values()) {
                for(DML_Outcome__c dla: dll){
                    if(dla.Field_API_Name__c != '' && dla.Field_API_Name__c != null && !query.contains(dla.Field_API_Name__c)){
                        query += ', ' + dla.Field_API_Name__c;
                    }
                }
            }
            query += ' from lead where id in:recordIds';   
        }*/
        
        query += contQuery+' FROM OpportunityContactRoles),Account.Name';
        query += oppQuery+accQuery+ ' from opportunity where id in:recordIds';
        system.debug(recordIds+query);
    }
    
    public SelfServeReportResultsUpdateOpp(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<opportunity> scope){
        
        map<id,lead>                mapFinalLead            = new map<id,lead>();
        list<contact>               ctUpdate                = new list<contact>();
        map<id,lead>                lsProspect              = new map<id,lead>();
        map<id,string>              mapIsPrimary            = new map<id,string>();
        map<id,string>              mapNoContactRoles       = new map<id,string>();
        map<id,string>              mapMultipleContRoles    = new map<id,string>();
        map<id,string>              mapSingleContRoles      = new map<id,string>();
        map<id,Opportunity>         mapOppDRes              = new map<id,Opportunity>();
        map<id,Account>             mapAccount              = new map<id,Account>();
        map<id,Contact>             mapContact              = new map<id,contact>();
        map<id,id>                  mapAccOpp               = new map<id,id>();
        map<id,Account>             mapAccOppRes            = new map<id,Account>();
        map<id,id>                  mapContOpp              = new map<id,id>();
        list<id>                    opid                    = new list<id>();
        for(opportunity op:scope){
            opid.add(op.id);
            noOppInReport++;
        }
        string opquery = 'select id,BDC_Manager__c'+oppQuery+' from opportunity where id in:opid';
        
        for(opportunity opd: Database.query(opquery)){
        
            mapOppDRes.put(opd.id,opd);
        }
        
        for(opportunity ops: scope){
            integer                                PContactRoles  = 0;
            
            mapAccOpp.put(ops.id,ops.accountid);
            if((!ops.Account.Open_Core_Opportunities__c) || (!dpRule)){
                map<id,map<id,id>>           ctrLMap = new map<id,map<id,id>>();
                for(OpportunityContactRole opr: ops.OpportunityContactRoles){
                    
                    if(opr.IsPrimary){
                        PContactRoles++;
                        mapContOpp.put(ops.id,opr.contactid);   

                        if(ctrLMap.size() >0 && ctrLMap.containsKey(ops.id)){
                            map<id,id>   tmpm = new map<id,id>();
                            tmpm = ctrLMap.get(ops.id);
                            tmpm.put(opr.contactid,ops.id);
                            ctrLMap.put(ops.id,tmpm);
                        }
                        else{
                            map<id,id>   tmpm = new map<id,id>();
                            tmpm.put(opr.contactid,ops.id);
                            ctrLMap.put(ops.id,tmpm);
                        }
                        
                              
                    }
                    
                }

                if(PContactRoles == ops.OpportunityContactRoles.size() && !ops.OpportunityContactRoles.isempty() && ops.OpportunityContactRoles.size() >1 && (ctrLMap.get(ops.id)).size()>1){
                    mapIsPrimary.put(ops.id,ops.id+',All the contact roles are primary and ignored for the Prospect creation\n');
                }

                if(ops.OpportunityContactRoles.isempty()){
                    mapNoContactRoles.put(ops.id,ops.id+',No Contact roles existin on the Opportunity\n');
                }
                
                if(PContactRoles == 0 && !ops.OpportunityContactRoles.isempty() && ops.OpportunityContactRoles.size() >1){
                    mapMultipleContRoles.put(ops.id,ops.id+',Multiple Contact roles but no Primary exist\n');
                }

                if(PContactRoles == 0 && !ops.OpportunityContactRoles.isempty() && ops.OpportunityContactRoles.size() ==1){
                    mapSingleContRoles.put(ops.id,ops.id+',One Contact exist but no Primary on it\n');
                }

            }

        }
        list<id>    accidA   = new list<id>();
        accidA.addall(mapAccOpp.values());
        string acQuery = 'select id'+accQuery+' from account where id in: accidA';
        system.debug('acQuery'+acQuery);
        for(Account acd: Database.query(acQuery)){
            mapAccount.put(acd.id,acd);
        }

        for(id opid1: mapAccOpp.keyset()){
                mapAccOppRes.put(opid1,mapAccount.get(mapAccOpp.get(opid1)));
        }
        list<id>            actid = new list<id>();
        actid.addall(mapContOpp.values());
        string             cQuery   = 'select id'+contQuery+' from contact where id in:actid'; 

        for(contact ct: Database.query(cQuery)){
            mapContact.put(ct.id,ct);    
        }

        for(opportunity ops: scope){
            if((!ops.Account.Open_Core_Opportunities__c) || (!dpRule)){
                if(!(mapMultipleContRoles.containsKey(ops.id) || mapNoContactRoles.containsKey(ops.id) || mapIsPrimary.containsKey(ops.id) || mapSingleContRoles.containsKey(ops.id) )){
                        for(OpportunityContactRole opr: ops.OpportunityContactRoles){
                            //call to find duplicates
                            list<contact> duplContactList = new list<contact>();
                            if(opr.IsPrimary){
                                
                                list<contact> conList               = new list<contact>();
                            
                                contact         ct                  = new contact();
        
                                ct.FirstName                        = opr.Contact.FirstName;   
                                ct.LastName                         = opr.Contact.LastName;
                                ct.Phone                            = opr.Contact.Phone;
                                ct.Email                            = opr.Contact.Email;
                                ct.MailingStreet                    = opr.Contact.MailingStreet;
                                ct.MailingCity                      = opr.Contact.MailingCity;
                                ct.MailingPostalCode                = opr.Contact.MailingPostalCode;
                                ct.Salutation                       = opr.Contact.Salutation;
                                ct.Company__c                       = opr.Contact.Company__c;
                                ct.Email_Domain__c                  = opr.Contact.Email_Domain__c;
                                ct.Open_Core_Opportunities__c       = 'True';
                                conList.add(ct);
                                if(dpRule){
                                    duplContactList = duplicateRecordFinder.findduplicateContacts(conList);
                                }
        
                            }
                            set<id>               crecid        = new set<id>();     
                        if(duplContactList.size()>0){
                            
                            for(contact cts:duplContactList){
                                crecid.add(cts.id);
                            }
                            
                            if(crecid.size()>0){
                                noProspectsSelected ++;
                                mapOpIdDuplicat.put(ops.id,ops.id + ',Active contract or Opportunity with matching contact,'+crecid+'\n');
                            }
                        }
                        else{
                            list<lead>          ledList = new list<lead>(); 
                                Lead                    ld = new lead();
                                ld.FirstName               = opr.Contact.FirstName;
                                ld.LastName                = opr.Contact.LastName;
                                ld.Phone                   = opr.Contact.Phone;
                                ld.Email                   = opr.Contact.Email;
                                ld.Street                  = opr.Contact.MailingStreet;
                                ld.City                    = opr.Contact.MailingCity;
                                ld.PostalCode              = opr.Contact.MailingPostalCode;
                                ld.Salutation              = opr.Contact.Salutation;
                                ld.Company                 = opr.Contact.Company__c;
                                ld.Email_Domain__c         = opr.Contact.Email_Domain__c;
                                ledList.add(ld);
                                set<id>     lrecid = new set<id>();
                                list<Lead> duplLeadList = new list<Lead>();
                                if(dpRule){
                                    duplLeadList = duplicateRecordFinder.findduplicateLeads(ledList);   
                                }
                                
                                if(!(duplLeadList.size()>0)){
                                    for(Lead cts:ledList){
                                        lsProspect.put(ops.id,cts);
                                        mapLdPros.put(opr.ContactId,cts);
                                        mapLeadList.put(ops.id,cts);
                                    }
                                }
                                else{
                                    Boolean HasIhascoorQMS=false;
                                    set<Id> leadIdsrec=new set<Id>();
                                    for(lead lds:duplLeadList){
                                        leadIdsrec.add(lds.Id);
                                    }
                                    List<Lead> dupleadlist=[Select Id,RecordType.Name From Lead where Id IN :leadIdsrec];
                                    for(lead lds:dupleadlist){
                                        if(lds.RecordType.Name=='Default IHASCO' || lds.RecordType.Name=='QMS Record Type'){
                                          HasIhascoorQMS=true;  
                                        }
                                        else{
                                            HasIhascoorQMS=false;
                                            lrecid.add(lds.id);
                                        }
                                    }
                                    if(lrecid.size()>0){
                                        noProspectsSelected ++;
                                        mapOpIdDuplicat.put(ops.id,ops.id+',Duplicate Prospect Found,'+lrecid+'\n');
                                    }
                                    else if(HasIhascoorQMS == true){
                                        for(Lead cts:ledList){
                                            cts.ByPass_Duplicate_Rules_Identifier__c=true;
                                            lsProspect.put(ops.id,cts);
                                            mapLdPros.put(opr.ContactId,cts);
                                            mapLeadList.put(ops.id,cts);
                                        }
                                    }
                                    
                                }

                        }
                        
                    }
                
                }
                else{
                    noContCantCreated ++;
                }
                }
                
            else{
                noProspectsSelected ++;
                mapOpIdDuplicat.put(ops.id,ops.id+',Opportunity Account has Open core opportunity \n');
            }

        }
            if(mapIsPrimary.size()>0){
                mapfinalErr.putall(mapIsPrimary);
            }

            if(mapNoContactRoles.size()>0){
                mapfinalErr.putall(mapNoContactRoles);
            }

            if(mapMultipleContRoles.size()>0){
                mapfinalErr.putall(mapMultipleContRoles);
            }

            if(mapSingleContRoles.size()>0){
                mapfinalErr.putall(mapSingleContRoles);
            }   

            if(mapOpIdDuplicat.size() >0){
                mapfinalErr.putall(mapOpIdDuplicat);
            }

            list<lead>                  finLeadList = new list<lead>();
            if(lsProspect.size() >0 ){

                for(id op: mapOppDRes.keyset()){
                    lead          slead  = new lead();
                    if(lsProspect.containsKey(op)){
                        slead       = mapLeadList.get(op);
                        for(list<DML_Outcome__c> dll:ACist.values()) {
                            for(DML_Outcome__c dla: dll){
                                if(dla.outcome__c != '' && dla.Field_API_Name__c != null){
                                    string so = dla.outcome__c;
                                    list<string>    splStr = new list<string>();
                                    list<string>    splStr1 = new list<string>();

                                    string gstr = '';                                
                                    if(mapOutcome.containsKey(so)){
                                        splStr = mapOutcome.get(so);
                                        splStr1 = splStr[0].split('\\.');
                                        gstr   = splStr[0];

                                    }
                                    if(so.contains('Opportunity.') && gstr != ''){
                                        slead.put(dla.Field_API_Name__c,mapOppDRes.get(op).get(gstr));
                                    }
                                    else if(!(so.contains('{') || so.contains('}'))){
                                        if(dla.Operator__c == 'Equals'){
                                            if(dla.Field_API_Name__c == 'RecordTypeId'){
                                               id  ldRcTypeId       = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(dla.outcome__c).getRecordTypeId();         
                                               slead.put((dla.Field_API_Name__c).trim(),ldRcTypeId);    
                                            }
                                            else{
                                                slead.put((dla.Field_API_Name__c).trim(),dla.outcome__c);
                                            }
                                            
                                        }
                                        else if(dla.Operator__c == 'Appends'){
                                            // Code block started here 
                                            // The below logic starts here to perform a logic to bring the BDC Manager Initials and append to Soure field along with the provided in the auromation configuration
                                            // SDT-3088
                                            
                                            if(dla.Field_API_Name__c == 'Source__c' && (dla.outcome__c != '' || dla.outcome__c != null) && ((string)mapOppDRes.get(op).get('BDC_Manager__c') !='' || (string)mapOppDRes.get(op).get('BDC_Manager__c') != null)){
                                                
                                                string             str  = (string)mapOppDRes.get(op).get('BDC_Manager__c');
                                                if(str != null){
                                                    list<string>       strl = str.split('\\s+');
                                                    string             str2 = strl[0].left(1);
                                                    string             str3 = strl[1].left(1);
                                                    string fCont =  str2+str3+' '+dla.outcome__c;
                                                    slead.put((dla.Field_API_Name__c).trim(),fCont);
                                                }
                                                else{
                                                    slead.put((dla.Field_API_Name__c).trim(),dla.outcome__c);
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        mapFinalLead.put(op,slead);
                    }
                }
                
                //similarly for Contact
                for(id op: mapContOpp.keyset()){
                    lead          slead  = new lead();
                    if(lsProspect.containsKey(op)){
                        slead       = mapLeadList.get(op);
                        for(list<DML_Outcome__c> dll:ACist.values()) {
                            for(DML_Outcome__c dla: dll){
                                if(dla.outcome__c != '' && dla.Field_API_Name__c != null){
                                    string so = dla.outcome__c;
                                    list<string>    splStr = new list<string>();
                                    list<string>    splStr1 = new list<string>();

                                    string gstr = '';                                
                                    
                                    if(mapOutcome.containsKey(so)){
                                        splStr = mapOutcome.get(so);
                                        splStr1 = splStr[0].split('\\.');
                                        if(splStr1.size()>1){
                                            gstr   = splStr1[1];
                                        }
                                    }

                                    if(so.contains('Contact.') && gstr != ''){
                                        system.debug('bham bham bhamare'+mapContact.get(mapContOpp.get(op)).get(gstr)+'dham dham '+dla.Field_API_Name__c);
                                        slead.put((dla.Field_API_Name__c).trim(),mapContact.get(mapContOpp.get(op)).get(gstr));
                                    }
                                }
                            }
                        } 
                        mapFinalLead.put(op,slead);              
                    }
                }
                //similarly for account
                
                for(id op: mapAccOpp.keyset()){
                    lead          slead  = new lead();
                    if(lsProspect.containsKey(op)){
                        slead       = mapLeadList.get(op);
                        for(list<DML_Outcome__c> dll:ACist.values()) {
                            for(DML_Outcome__c dla: dll){
                                if(dla.outcome__c != '' && dla.Field_API_Name__c != null){
                                    string so = dla.outcome__c;
                                    list<string>    splStr = new list<string>();
                                    list<string>    splStr1 = new list<string>();

                                    string gstr = '';                                
                                    if(mapOutcome.containsKey(so)){
                                        splStr = mapOutcome.get(so);
                                        splStr1 = splStr[0].split('\\.');
                                        if(splStr1.size() > 1){
                                            gstr   = splStr1[1];
                                        }
                                        
                                    }
                                    if(so.contains('Account.') && gstr != ''){
                                        slead.put((dla.Field_API_Name__c).trim(),mapAccOppRes.get(op).get(gstr));
                                    }
                                }
                            }
                        } 
                       mapFinalLead.put(op,slead);              
                    }
                }
                if(mapFinalLead.size() > 0){
                    database.insert(mapFinalLead.values(),false);
                }
                list<opportunity>             closedLP   = new list<opportunity>();
                for(id mid: mapFinalLead.keyset()){
                    if(mapFinalLead.get(mid).id != null){
                        noProspecsCreated ++;
                        opportunity optemp = new opportunity();
                        optemp.id = mid;
                        optemp.Closed_lost_prospect_id_created__c = mapFinalLead.get(mid).id;
                        closedLP.add(optemp);
                    }
                }
                list<Lead> LeadstoUpdate= new list<Lead>();
                for(id mid: mapFinalLead.keyset()){
                    if(mapFinalLead.get(mid).id != null && mapFinalLead.get(mid).ByPass_Duplicate_Rules_Identifier__c){
                        mapFinalLead.get(mid).ByPass_Duplicate_Rules_Identifier__c=false;
                        LeadstoUpdate.add(mapFinalLead.get(mid));
                    }
                }
                if(!LeadstoUpdate.isEmpty()){
                    database.update(LeadstoUpdate,false);  
                }

                //Post Prospect creation Update Opportunity with the Prospect Id
                if(closedLP.size()>0){
                    database.update(closedLP,false);
                }
                //insert lsProspect.values();     
            }

    }
    
    global void finish(Database.BatchableContext bc){
        Automation_Configuration__c acLi = new Automation_Configuration__c();
            string msgStr = 'Closed Lost Opportunity ID,Reason,Duplicates Found \n';
            string msgStr1 = '';
            
            if(mapfinalErr.size() >0){
                for(id oid:mapfinalErr.keyset()){
                    msgStr = msgStr + mapfinalErr.get(oid);
                }
    
            }
            else{
                msgStr = ',No exclusions all successfull \n';
            }
            msgStr = msgStr;
            msgStr1 = '<br>The following is the summary of the Overall Closed Lost Prospect Creation Job execution<br><br><br>';
            msgStr1 = msgStr1 + 'Number of Opportunities on the report :<b>'+noOppInReport+'</b><br>';
            msgStr1 = msgStr1 + 'Record matched to existing record :<b>'+noProspectsSelected+'</b><br>';
            msgStr1 = msgStr1 + 'No Contact cannot create :<b>'+noContCantCreated+'</b><br>';
            
            msgStr1 = msgStr1 + 'Number of prospects created           :<b>'+noProspecsCreated+'</b><br><br>';
            //msgStr = msgStr1 + msgStr ;
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        	blob excel = blob.valueOf(msgStr);
            system.debug('excelblob111'+excel);
            attach.setBody(excel);
            attach.setFileName('ClosedLost_'+reportName+'_'+date.today().format()+'.csv');
            
        	Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setsubject('Closed Lost Prospect Creator for Report: '+reportName);
            mail1.setHtmlBody(  msgStr1  );
            mail1.setToAddresses(toAddresses);
        	mail1.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});

            for(id a: ACist.Keyset()){
                acLi.Processed__c = 'Yes';
                acLi.id = a;
            }
            update acLi;
        
            id lareI = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
            list<id> lsd = new list<id>();
            lsd.add(lareI);
            list<Automation_Configuration__c> lac = [SELECT Id,Processed__c,recordtypeid from Automation_Configuration__c where Processed__c = 'No' and recordtypeid =: lsd ];
        
            if(lac.size()>0){
                Database.executeBatch(new SelfServeReportResultsFetchOpp(), 2000);
            }
            else{
                id UserId =(Id)UserInfo.getUserId();
                User                        toUp = new User();
                toUp.id = UserId;
                toUp.Run_Duplicate_Rules__c = false;
                update toUp;
            }
        
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SelfServeReportResultsUpdateOpp(), 250);
    }

}