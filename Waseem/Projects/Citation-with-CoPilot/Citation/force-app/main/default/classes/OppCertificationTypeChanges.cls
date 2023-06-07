public class OppCertificationTypeChanges {
    @InvocableMethod(label='Get Opportunities' description='Returns the before context list of Opportunities changes' category='Opportunity')
    public static void getOppChanges(List<Opportunity> opps) {
        list<opportunity> oppList = new list<opportunity>();
        for(opportunity op:opps){
            opportunity opr = new opportunity();
            String s1 = op.Certification__c;
            String replacement = '';
            String s2 = s1;
            String regExp = '';
            if(s1 != null && s1.contains(': ')){
                regExp = ':.[0-9][0-9][0-9][0-9]';
                s2 = s1.replaceAll(regExp, replacement);
            }
            if(s2 != null && s2.contains(':')){
                regExp = ':[0-9][0-9][0-9][0-9]';
                s2 = s2.replaceAll(regExp, replacement);
            }
            opr.id = op.id;
            opr.Certificate_Display_New__c = s2;
            oppList.add(opr);
        }
        if(oppList.size()>0){
            update oppList;
        }

    }
}