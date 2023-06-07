public with sharing class bg_LogsHelper {
	public final String DEFAULT_LOGS_FIELD = 'Logs__c';
	// public static String className {get; set;}
	// public static String methodName {get; set;}

	private static bg_LogsHelper logHelper {get; set;}
	private String className {get; set;}
	private String methodName {get; set;}

	public bg_LogsHelper(String className, String methodName) {
		this.className = className;
		this.methodName = methodName;
	}

    public bg_LogsHelper() {
        
    }

	public static Boolean setupVariables(String className, String methodName) {
		logHelper = new bg_LogsHelper(className, methodName);

		logHelper.className = className;
		logHelper.methodName = methodName;

		return false;
	}

	public static Boolean populateLog(sObject record, String message, String className, String methodName) {
        setupVariables(className, methodName);
        if(record != null)
        {
            String existingMessage = '';
            if (record.get(logHelper.DEFAULT_LOGS_FIELD) != null)
            {
                existingMessage = String.valueOf(record.get(logHelper.DEFAULT_LOGS_FIELD));
            }
            //String existingMessage = record.get(logHelper.DEFAULT_LOGS_FIELD) != null ? String.valueOf(record.get(logHelper.DEFAULT_LOGS_FIELD)) : '';
            existingMessage += logHelper.generateMessage(message);
            record.put(logHelper.DEFAULT_LOGS_FIELD, existingMessage);
        }

    	return false;
    }

    @testVisible private final String MESSAGE_TEMPLATE = '[{0}][{1}][{2}]: {3}\r\n\n';
    @testVisible private String generateMessage(String message) {
    	String messageDateTime = String.valueOf(DateTime.now());
    	return String.format(MESSAGE_TEMPLATE, new List<String> {messageDateTime, this.className, this.methodName, message});
    }

    // public static Map<Id, String> logMap {get; set;}

    // public static Boolean addLog(Id recordId, String message) {
    // 	if(logMap == null)
    // 	{
    // 		logMap = new Map<Id, String>();
    // 		logMap.put(recordId, message);
    // 	}
    // 	else if(logMap.containsKey(recordId))
    // 	{
    // 		String tmp = logMap.get(recordId);
    // 		tmp += message;
    // 		logMap.put(recordId, tmp);
    // 	}
    // 	else
    // 	{
    // 		logMap.put(recordId, message);
    // 	}

    // 	return false;
    // }

    // private static String MESSAGE_TEMPLATE = '[{0}][{1}][{2}]: {3}\r\n';
    // public static String generateMessage(String classNameIn, String methodIn, String message) {
    // 	String messageDateTime = String.valueOf(DateTime.now());
    // 	return String.format(MESSAGE_TEMPLATE, new List<String> {messageDateTime, classNameIn, methodIn, message});
    // }

    // public static String generateMessage(Object className, String method, String message) {
    // 	String messageDateTime = String.valueOf(DateTime.now());
    // 	String name = String.valueOf(className).split(':')[0];//returns MyClass
    // 	return String.format(MESSAGE_TEMPLATE, new List<String> {messageDateTime, name, method, message});
    // }

    //String name = String.valueOf(mc).split(':')[0];//returns MyClass

    // public static Boolean populateLogs(List<sObject> records, String field) {
    // 	for(sObject record : records)
    // 	{
    // 		if(logMap.containsKey(record.Id))
    // 		{
    // 			String existingMessage = String.valueOf(record.get(field));
    // 			existingMessage += logMap.get(record.Id);
    // 			record.put(field, existingMessage);
    // 		}
    // 	}

    // 	return false;
    // }

  //   public static Boolean populateLog(sObject record, String field, String message) {
		// String existingMessage = record.get(field) != null ? String.valueOf(record.get(field)) : '';
		// existingMessage += message;
		// record.put(field, existingMessage);

  //   	return false;
  //   }

    
}