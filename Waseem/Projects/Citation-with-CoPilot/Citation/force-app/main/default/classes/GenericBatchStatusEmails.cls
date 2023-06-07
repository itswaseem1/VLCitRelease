public class GenericBatchStatusEmails {
    
    public static void sendEmail(String body , String sub , List<String> mailidsList)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = mailidsList;
        mail.setToAddresses(toAddresses);
        mail.setSubject(sub);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static Messaging.SingleEmailMessage BuildEmail(String body , String sub , List<String> mailidsList){        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = mailidsList;
        mail.setToAddresses(toAddresses);
        mail.setSubject(sub);
        mail.setPlainTextBody(body);
        return mail;
    }
    
    public static void SendBulkEmail(List<Messaging.SingleEmailMessage> emails){
        if(!emails.isEmpty()){       
            Messaging.sendEmail(emails);
        }
    }
    
    Public static void CustomExceptionMail(Exception e, String Subject , String records , List<String> mailidsList){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = mailidsList;
        mail.setToAddresses(toAddresses);
        mail.setSubject(Subject);
        if(e != null){
	        mail.setHtmlBody('An Exception occured of <b> ' + e.getTypeName() +' </b> with Error msg ' + e.getMessage() + ' at line ' + e.getLineNumber() + '.<p>'+
                             'The original record under scope were ' + records +' <p>' +
                             'Stack trace ' + e.getStackTraceString());
        }
        else{
            mail.setHtmlBody('<p>'+'The original record under scope were ' + records +' <p>');
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}