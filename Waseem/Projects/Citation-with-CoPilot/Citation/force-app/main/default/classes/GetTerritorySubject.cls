/* This class is used in 'Create Site Visit Records on Service Appointment Completion' 
flow to get the list of subjects of H&S Territory and EL&HR territory
*/
public class GetTerritorySubject {
    @InvocableMethod(label='Get Territory Subjects' Description='Get Territory Subjects')
    public static list<list<String>> getSubjectsTerritory(list<String> territory){
        list<list<string>> subjectlist=new list<list<string>>();
        list<Service_appointment_subject__mdt> listsubj=[select id,subject__c from Service_appointment_subject__mdt where  Label =:territory limit 1];
       if(listsubj.size()>0){
                subjectlist.add(listsubj[0].subject__c.split(','));
              }
        return subjectlist;
    }
}