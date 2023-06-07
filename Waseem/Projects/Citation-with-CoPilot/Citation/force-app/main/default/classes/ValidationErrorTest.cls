@isTest
public class ValidationErrorTest
{
    @isTest
    private static void getterReturnValues()
    {
        SObject obj = new Account(Name = 'bob');
        ValidationError error = new ValidationError(obj, 'Name', 'Bad Act');

        System.assertEquals(obj, error.getRecord());
        System.assertEquals('Name', error.getField());
        System.assertEquals('Bad Act', error.getMessage());
    }

    @isTest
    private static void addErrorOnObject()
    {
        SObject obj = new Account(Name = 'bob');
        ValidationError error = new ValidationError(obj, 'Bad Act');
        error.convertToAddError();

        System.assertEquals(1, obj.getErrors().size());
        System.assertEquals('Bad Act', obj.getErrors().get(0).getMessage());
    }

    @isTest
    private static void addErrorOnField()
    {
        SObject obj = new Account(Name = 'bob');
        ValidationError error = new ValidationError(obj, 'Name', 'Bad Act');
        error.convertToAddError();

        System.assertEquals(1, obj.getErrors().size());
        System.assert(obj.getErrors().get(0).getFields().contains('Name'), 'expected to find name field, found : ' + obj.getErrors().get(0).getFields());
    }

    @isTest
    private static void throwExceptionOnObject()
    {
        SObject obj = new Account(Name = 'bob');
        ValidationError error = new ValidationError(obj, 'Bad Act');

        try 
        {
            error.convertToException();
            System.assert(false, 'Should have thrown exception');    
        } 
        catch (Exception e)
        {
            System.assertEquals('Bad Act', e.getMessage());
        }
    }

    @isTest
    private static void throwExceptionOnField()
    {
        SObject obj = new Account(Name = 'bob');
        ValidationError error = new ValidationError(obj, 'Name', 'Bad Act');
        try 
        {
            error.convertToException();
            System.assert(false, 'Should have thrown exception');    
        } 
        catch (Exception e)
        {
            System.assertEquals('Bad Act', e.getMessage());
        }
    }
}