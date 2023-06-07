/**
* @File Name          : SAEmailTemplateInfoController.apx
* @Description        : To get related field of serviceappointment to use in Email Templates.
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
public with sharing class SAEmailTemplateInfoController {
    public Id serviceApoointmentId{get;set;}
    public List<AssignedResource> getserviceApoointmentLists()
    {
        List<AssignedResource> assignedResourceList;
        
        assignedResourceList =[Select Id, ServiceAppointmentId, ServiceResource.RelatedRecord.Name, ServiceResource.RelatedRecord.Title, ServiceResource.RelatedRecord.Phone, ServiceResource.RelatedRecord.MobilePhone
                 from AssignedResource where ServiceAppointmentId = : ServiceApoointmentId Limit 1];
           
        return assignedResourceList;
    }
    public List<ServiceAppointment> getserviceApoointmentListsForTemp()
    {
        List<ServiceAppointment> serviceAppointmentList;
        
        serviceAppointmentList =[Select Id, contact.FirstName, Address, Street,City, state, postalCode, Country, visit_type__c, Meeting_type__c, Customer_Friendly_Meeting_Name__c, AppointmentNumber, SchedStartTime 
                 from ServiceAppointment where Id = : ServiceApoointmentId Limit 1];
           
        return serviceAppointmentList;
    }
    
   
}