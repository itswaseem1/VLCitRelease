public inherited sharing class ValidationError
{
    private SObject record;
    private String field;
    private String message;

    public ValidationError(SObject record, String field, String message)
    {
        this.record = record;
        this.field = field;
        this.message = message;
    }

    public ValidationError(SObject record, String message)
    {
        this.record = record;
        this.field = field;
        this.message = message;
    }

    public void convertToAddError()
    {
        if(field != null)
        {
            record.addError(field, message);
        }               
        else
        {
            record.addError(message);    
        }
    }

    public void convertToException()
    {
        throw new ValidationException(message);
    }

    public SObject getRecord()
    {
        return record;
    }

    public String getField()
    {
        return field;
    }

    public String getMessage()
    {
        return message;
    }

    public class ValidationException extends Exception
    {
    }
}