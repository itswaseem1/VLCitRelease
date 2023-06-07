/**
 * @File Name          : ServiceAppQMSAddressUpdate.cls
 * @Description        : TO update address on Service Appointment.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 8/11/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     08/11/2021.      Initial Version
 **/
public with sharing class ServiceAppQMSAddressUpdate {
    private static string blank = null; 
    private static Map<id,AssignedResource> sAToAssgnedResourceMap = new Map<id,AssignedResource>();
    private static Map<id,ServiceTerritoryMember> assgnedResourceToStmMap = new Map<id,ServiceTerritoryMember>();
    private static List<id> serviceResourceIdsList = new List<id>();
    private static List<ServiceAppointment> updateSAAddressList = new List<ServiceAppointment>();
    @InvocableMethod(label='Update QMS SA Address' description='Update QMS SA Address')
    public static void updateServiceAppintmentAddress(List<id> saIds)     
    {
        

        List<AssignedResource> assignedResourcelist = [select id,ServiceAppointmentId,ServiceResourceId 
                                                      from AssignedResource
                                                      Where ServiceAppointmentId IN :saIds 
                                                      WITH SECURITY_ENFORCED
                                                      ];
        for(AssignedResource arloop : assignedResourcelist)
        {
            sAToAssgnedResourceMap.put(arloop.ServiceAppointmentId, arloop);
            serviceResourceIdsList.add(arloop.ServiceResourceId);
        }
        List<ServiceTerritoryMember> serviceTerritoryMemberList = [select id,ServiceResourceId,street,city,
                                                                   state,country,PostalCode
                                                      from ServiceTerritoryMember
                                                      Where ServiceResourceId IN :serviceResourceIdsList
                                                      AND TerritoryType='P'
                                                      WITH SECURITY_ENFORCED
                                                      ];
        for(ServiceTerritoryMember stmloop : serviceTerritoryMemberList)
        {
            assgnedResourceToStmMap.put(stmloop.ServiceResourceId, stmloop);
        }
       
        for(ServiceAppointment saloop:[select id,street,city,country,state,postalcode,Visit_Type__c,status
                                       from ServiceAppointment
                                       Where id IN:saIds WITH SECURITY_ENFORCED])
        {
            /*if(
              saloop.street==blank && saloop.city==blank && saloop.state==blank && 
               saloop.PostalCode==blank && saloop.country==blank
              ){*/
            if(sAToAssgnedResourceMap!=null && assgnedResourceToStmMap!=null && assignedResourcelist.size()>0)
        {
                saloop.street=assgnedResourceToStmMap.get(sAToAssgnedResourceMap.get(saloop.id).ServiceResourceId).street; 
                saloop.city=assgnedResourceToStmMap.get(sAToAssgnedResourceMap.get(saloop.id).ServiceResourceId).city; 
                saloop.state=assgnedResourceToStmMap.get(sAToAssgnedResourceMap.get(saloop.id).ServiceResourceId).state;  
                saloop.PostalCode=assgnedResourceToStmMap.get(sAToAssgnedResourceMap.get(saloop.id).ServiceResourceId).postalCode;
                saloop.country=assgnedResourceToStmMap.get(sAToAssgnedResourceMap.get(saloop.id).ServiceResourceId).country;
                updateSAAddressList.add(saloop);
        }
        else{
                saloop.street= ''; 
                saloop.city=''; 
                saloop.state='';  
                saloop.PostalCode='';
                saloop.country='';
                updateSAAddressList.add(saloop);
        }
        }
        if(updateSAAddressList.size()>0 && ServiceAppointment.sObjectType.getDescribe().isUpdateable())
        {
            try{
        	update updateSAAddressList;
            }Catch(Exception e){
                System.debug('Exception on address update'+ e);
            }
        }
    
}


}