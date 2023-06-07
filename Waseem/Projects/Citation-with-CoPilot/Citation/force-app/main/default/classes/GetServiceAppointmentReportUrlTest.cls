@isTest
public class GetServiceAppointmentReportUrlTest {
    @istest(seealldata=true)
    public static void getreportUrlWhenReportFound()
    {
        Report[] report=[select id from report where name='Overdue Appointments to filter'];
        string postalcode='test 2k';
        string reportUrl=GetServiceAppointmentReportUrl.getUrl(postalcode);
        string url= URL.getSalesforceBaseUrl().toExternalForm();
        system.assertEquals(url+'/lightning/r/Report/'+report[0].id+'/view?fv0='+postalcode,reportUrl);
    }
    @isTest
    public static void getreportUrlWhenNoReportFound()
    {
        string postalcode='test 2kn';
        string reportUrl=GetServiceAppointmentReportUrl.getUrl(postalcode);
        system.assertEquals(null,reportUrl);
    }
}