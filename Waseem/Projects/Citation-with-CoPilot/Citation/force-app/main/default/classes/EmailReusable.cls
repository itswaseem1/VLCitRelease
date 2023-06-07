global class EmailReusable{
   
    @InvocableMethod(label='Send Emails' description='This method sends the emails per metadata configuration from processes')
    global static void sendEmail (list<String> recidList){
        System.debug('I am inside reusable method');
        System.debug('Record Id List'+recidList);
        List<Schema.FieldSetMember>  queryfl;
        
        List<String> parts = recidList[0].split('-');
        //This assumes that you have passed at least 3 characters
        id recordIdOrPrefix = (ID)parts[0]; 
        string multipleRec = 'false';
        if(parts.size() >2){
        	multipleRec = parts[2];    
        }
        String sObjName = recordIdOrPrefix.getSObjectType().getDescribe().getName();
        if(sObjName == 'Lead'){
            queryfl = SObjectType.Lead.FieldSets.Email_ReUsable_Field_Set.getFields();
        }
        else if(sObjName == 'Opportunity'){
            queryfl = SObjectType.Opportunity.FieldSets.Opportunity_Email_Alerts.getFields();
        } else if (sObjName == 'Event'){
            queryfl = SObjectType.Event.FieldSets.Event_Reusable_Field_Set.getFields();
        }
        else if(sObjName == 'Visit_Report__c'){
            queryfl = SObjectType.Visit_Report__c.FieldSets.Visit_Report_Email_Alerts.getFields();
        }
        list<Email_Alert__mdt> emalertmd = [select id,Additional_Emails__c,Organization_Wide_Email_Name__c,Email_Template_Name__c,Object_Name__c,Object_Prefix__c,Recipient_Type_Email__c,Stamp_On__c,MasterLabel,DeveloperName from Email_Alert__mdt where Email_Template_Name__c In: parts];
        list<string> recfields = emalertmd[0].Recipient_Type_Email__c.split(';');
        string stamp = emalertmd[0].Stamp_On__c;
        list<string> owaname = new list<string>();
        owaname.add(emalertmd[0].Organization_Wide_Email_Name__c);
        list<string> emtemplatename = new list<string>();
        emtemplatename.add(emalertmd[0].Email_Template_Name__c);
        list<string> emList = new list<string>();
        
        Boolean EmailToWhoId = false;
        Boolean EmailToInvitees = false;
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : queryfl) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM '+ sObjName +' where id In: parts';
        system.debug('query+++'+query);
        list<SObject>  ldList = Database.query(query);
        for(SObject lds: ldList){
            for(string st:recfields){
                 if(sObjName == 'Event' && st== 'WhoId'){ 
                    EmailToWhoId = true;
                } else if(sObjName == 'Event' && st== 'Invitees'){
                 	EmailToInvitees = true;   
                }
                else if(st != 'null'){
                    if(multipleRec == 'true'){
                    	string emaillst =  (string)lds.get(st);
                    	emList = emaillst.split(';');  
                    } 
                    else 
                emList.add((string)lds.get(st));
            }
            }
            if(emalertmd[0].Additional_Emails__c != null && emalertmd[0].Additional_Emails__c != ''){
                for( string st: emalertmd[0].Additional_Emails__c.split(';')){
                    if(!emList.contains(st)){
                        emList.add(st);
                    }
                }
            }
        }
        List<Event> events = new List<Event>();
        if(sObjName == 'Event'){
            events = [SELECT Whoid , ownerId from Event where id IN: parts];
        }
        
        if(sObjName == 'Event' && EmailToWhoId){
            if(events != NULL && events.size() != 0){
                if( events[0].WhoId != NULL &&  String.valueOf(events[0].WhoId).Startswith('003')){
                    For(Contact c: [SELECT ID, Email from Contact where id = :events[0].WhoId ]){
                        if(!emList.contains((String)c.Email)){
                            emList.add((String)c.Email);
                        }
                    }
                }
                else if(events[0].WhoId != NULL &&  String.valueOf(events[0].WhoId).Startswith('00Q')){
                    For(Lead l: [SELECT ID, Email from Lead where id = :events[0].WhoId ]){
                        if(!emList.contains((String)l.Email)){   
                            emList.add((String)l.Email);
                        }
                    }
                }
            } 
        }
        
        if(sObjName == 'Event' && EmailToInvitees){
            List<id> userInvitees = new List<id>();
            List<id> prospectInvitees = new List<id>();
            List<id> ContactInvitees = new List<id>();
            For(EventRelation eventRel : [SELECT id, RelationId from EventRelation where EventId IN: Parts]){
                if(String.valueOf(eventRel.RelationId).StartsWith('003')){
                  ContactInvitees.add((ID)eventRel.RelationId);  
                }  else if(String.valueOf(eventRel.RelationId).StartsWith('00Q')){
                    prospectInvitees.add((ID)eventRel.RelationId);  
                } else if(String.valueOf(eventRel.RelationId).StartsWith('005')){
                    userInvitees.add((ID)eventRel.RelationId);
                }
            }
            if(userInvitees != NULL && userInvitees.SIZE() != 0){
                for(user u : [Select id, Email from User where id IN :userInvitees]){
                    if((u.Email != NULL && u.Email != '') &&(!emList.contains((String)u.Email))){   
                        emList.add((String)u.Email);
                    }
                }
            }
            if(prospectInvitees != NULL && prospectInvitees.SIZE() != 0){
                for(Lead l : [Select id, Email from Lead where id IN :prospectInvitees]){
                    if((l.Email != NULL && l.Email != '') && (!emList.contains((String)l.Email))){   
                        emList.add((String)l.Email);
                    }
                }
            }
            if(ContactInvitees != NULL && ContactInvitees.SIZE() != 0){
                for(Contact c : [Select id, Email from Contact where id IN :ContactInvitees]){
                    if((c.Email != NULL && c.Email != '') && (!emList.contains((String)c.Email))){   
                        emList.add((String)c.Email);
                    }
                }
            }
        }
        OrgWideEmailAddress  owa = [SELECT id,DisplayName FROM OrgWideEmailAddress where DisplayName In: owaname  limit 1];
        list<EmailTemplate> templteLST = [SELECT BrandTemplateId,DeveloperName,Id,Name FROM EmailTemplate where DeveloperName In : emtemplatename];
        if(sObjName != 'Event' || (sObjName == 'Event' && !emList.isEmpty()) ){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.templateId = templteLST[0].id;
            if(String.valueOf(recordIdOrPrefix).startsWith('00Q')){
                message.targetobjectid=recordIdOrPrefix;
            }
            else {
            message= Messaging.renderStoredEmailTemplate((String)templteLST[0].id, null,recordIdOrPrefix); 
            }
            if(!emList.isEmpty()){
                message.toAddresses = emList;
            }
            message.treattargetobjectasrecipient = false;
            message.orgwideemailaddressid = owa.id;
            if(sObjName == 'Event'){
                message.setSaveAsActivity(false);
            } else{
            message.setSaveAsActivity(true);
            }
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            String mailTextBody = message.getPlainTextBody();
            String mailHtmlBody = message.getHTMLBody();
            String mailSubject = message.getSubject();
        
            if (results[0].success) {
                Map<Id, String> idsToUpdate = new Map<Id, String>();
                list<sobject> lso = new list<SObject> ();

            if(stamp != 'null'){
                    system.debug('stamp'+stamp);
                    sobject stpfield = ldList[0];
                    stpfield.put(stamp,system.now());
                    update stpfield;
                }
            
                if(sObjName == 'Event'){
                    Attachment attachment = new Attachment();
                    if(mailHtmlBody != NULL && mailHtmlBody != ''){
                        attachment.Body = Blob.valueof( mailHtmlBody );
                        attachment.Name = String.valueOf('EventEmail.html');
                    } else{
                        attachment.Body = Blob.valueof(mailTextBody);
                        attachment.Name = String.valueOf('EventEmail.txt');
                    }
                    
                    attachment.OwnerId = events[0].ownerId;
                    attachment.ParentId = recordIdOrPrefix;
                    insert attachment;
                }
            
            } else {
                System.debug('The email failed to send: '
                    + results[0].errors[0].message);
            }
        }
    }
    @AuraEnabled
    public static void sendEmailV(string recDet){
        list<string> recidList = new list<string>(); 
        recidList.add(recDet);
        sendEmail(recidList);
    }
}