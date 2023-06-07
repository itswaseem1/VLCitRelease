/**
* @File Name          : SAEmailReminderBatch.apx
* @Description        : Batch Class
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 8/9/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    6/15/2021      Initial Version            SS-518
**/
public without sharing class SAEmailReminderBatch implements Database.Batchable<sObject> {
         
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
    Date currentDate = System.today().addDays(3);
   	return Database.getQueryLocator([Select Id, contact.FirstName, contact.MobilePhone, Status, ServiceTerritory.Name, Milestone_Work_Type__r.Milestone_Template__r.Business__c, Address, Street,City, state, postalCode, Country,
                                         visit_type__c, Meeting_Type__c, Customer_Friendly_Meeting_Name__c, AppointmentNumber, SchedStartTime 
                 						 from ServiceAppointment Where Status = 'Dispatched' AND Milestone_Work_Type__r.Milestone_Template__r.Business__c = 'Citation' AND 
                                   		  ServiceTerritory.Name in ('H&S Territory', 'EL / HR Territory', 'Atlas On-Boarding', 'Onsite HR Territory')                                         
                                     		AND DAY_ONLY(SchedStartTime) = : currentDate WITH SECURITY_ENFORCED]);

    }

    public void execute(Database.BatchableContext bc, List<ServiceAppointment> serAppList) {
          SAEmailReminderBatchHelper.setupReminderEmailData(serAppList);
		
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('Batch Execution Finished');

    }
    


}