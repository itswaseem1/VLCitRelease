public class PercentPopScheduledJobHelper {
    public static String AllFields(String ObjectName,Set<Id> revIds) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        String query  = 'SELECT '+String.join(fields, ',')+' FROM '+ObjectName+' WHERE Id IN: revIds';
        return query;
    }
}