public with sharing class FetchReportResults {
    public FetchReportResults() {

    }

    public list<id> getRecordIdList(string reportid,string objectName){
        // Get the report ID
        String key = 'T!T';
        List<id> ids = new List<id>();
        Reports.ReportResults results = Reports.ReportManager.runReport(reportid, true);    //We can write a query to get report Id for any report.
        Reports.ReportMetadata rm = results.getReportMetadata();                //to get the metadata
        List<String> detailColumns = rm.getDetailColumns();    
        system.debug(detailColumns);
        Integer index = 0;
        Reports.ReportFactWithDetails factMap = (Reports.ReportFactWithDetails)results.getFactMap().get(key);   //T!T key stores all data of tabular report
        List<Reports.ReportDetailRow> rows = factMap.getRows();
        for(Reports.ReportDetailRow row : rows)
        {
            Reports.ReportDataCell leadId = row.getDataCells()[index];          //fetching id column of all report rows
            ids.add((ID)(leadId.getValue()));                                           //taking value of id
        }
        return ids;
    }   
}