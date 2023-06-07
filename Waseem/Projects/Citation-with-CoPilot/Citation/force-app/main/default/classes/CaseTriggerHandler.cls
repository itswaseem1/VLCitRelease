public with sharing class CaseTriggerHandler {
    
    public static List<Case> atlasSupportCases = new List<Case>();
    public static List<Case> adviseGenericCases = new List<Case>();
    
    public static final Id ATLAS_SUPPORT_RECORD_TYPE =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
    public static final Id ELT_ADVISE_RECORD_TYPE =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
    public static final Id HS_ADVISE_RECORD_TYPE =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HS_Advice_Generic').getRecordTypeId();
    
    //filter Cases by record type
    public static void filterCasesByRecordType(List<Case> cases) {
        for (Case caseItem : cases) {
            if (caseItem.RecordTypeId == ATLAS_SUPPORT_RECORD_TYPE) {
                atlasSupportCases.add(caseItem);
            } else if (caseItem.RecordTypeId == ELT_ADVISE_RECORD_TYPE || caseItem.RecordTypeId == HS_ADVISE_RECORD_TYPE) {
                adviseGenericCases.add(caseItem);
            }
        }
    }
    
    // create Employee_Matter__c for new Advise Generic cases (Employee__c not null)
    public static void createEmployeeMatterForNewAdviceCases() {
        if (adviseGenericCases.isEmpty()) {
            return;
        }
        EmployeeMattersGenerator.createEmployeeMatterForNewAdviceCases(adviseGenericCases);
    }
    
    // create Employee_Matter__c for updated Advise Generic cases (Employee__c was changed)
    public static void updateEmployeeMatterForAdviceCases(Map<Id, Case> oldCases) {
        if (adviseGenericCases.isEmpty()) {
            return;
        }
        EmployeeMattersGenerator.updateEmployeeMatterForAdviceCases(oldCases, adviseGenericCases);
    }
    
    //Check for Auto Response Cases
    public static void checkAutoResponseCases(List<Case> cases){
        List<Case> filteredCaseList = new List<Case>();
        for(Case objCase : cases){
            if(objCase.SuppliedEmail != null && objCase.SuppliedEmail != '' && objCase.Subject !='New contact message from Citation'){
                filteredCaseList.add(objCase);
            }
        }
        
        if(filteredCaseList.isEmpty())
            return;
        
        Group quarantineQueue = [Select Id from Group where type='Queue' and Name='Quarantine'];
        
        for(Case objCase : filteredCaseList){
            Boolean verifyEmail = checkForEmailPatterns(objCase.SuppliedEmail);
            if(verifyEmail){
                objCase.OwnerId = quarantineQueue.Id;
            }else{
                checkForKeywords(objCase,quarantineQueue);
            } 
        }
    }
    
    public static Boolean checkForEmailPatterns(String suppEmail){
        String email = suppEmail.toLowerCase();
        String noreplyRegex = '^no.?reply.*$';
        String mailerDaemonRegex = '^mailer.?daemon+@.*$';
        Pattern noReplyPattern = Pattern.compile(noreplyRegex);
        Matcher matchNoReply = noReplyPattern.matcher(email); 
        Pattern mdPattern = Pattern.compile(mailerDaemonRegex);
        Matcher matchMD = mdPattern.matcher(email);
        Boolean chk = (matchNoReply.matches() || matchMD.matches());
        return chk;
    }
    
    public static void checkForKeywords(Case c,Group quarantineQueue){
        List<String> avoidKeywords = (Label.Disabled_Email_Keywords).split(',');
        for(String key : avoidKeywords){
            if(c.Subject != null && c.Subject != '' && (c.Subject).containsIgnoreCase(key)){
                c.OwnerId = quarantineQueue.Id;
                break;
            }
        }
    }
}