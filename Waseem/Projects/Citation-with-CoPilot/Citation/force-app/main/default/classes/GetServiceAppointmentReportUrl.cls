/**
* @File Name          : GetServiceAppointmentReportUrl.cls
* @Description        : To get Report URL(to serach list of service appointments based on postal code)
* @Author             : Priyanka
**/
public without sharing class GetServiceAppointmentReportUrl {
    @AuraEnabled(cacheable=true)
    public static string getUrl(string postalCode){
        Report[] report=[select id from report where name='Overdue Appointments to filter' limit 1];
        if(!report.isEmpty()){
            return URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Report/'+report[0].id+'/view?fv0='+postalCode;
        }
        return null;
    }
}