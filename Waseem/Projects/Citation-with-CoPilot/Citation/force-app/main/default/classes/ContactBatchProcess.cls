// this doesn't appear to be used, check for this later. (in case it is manually scheduled etc)
public class ContactBatchProcess implements Database.Batchable<sObject>
{
   public Database.QueryLocator start(Database.BatchableContext BC)
   {
      string qrlimit = system.label.Batch_Limit_Label;
      String query ='SELECT Id,LastName,AccountId,FirstName,Email,Account.Shorthorn_Id__c,HasOptedOutOfEmail,IndividualId,QMS_Individual__c FROM contact where IndividualId= null and accountid != null and email != null limit '+ qrlimit;
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<contact> scope)
   {
        list<contact> conListToUpdate= new LegacyContactTriggerHandler.UpdateIndividuals().IndividualPopulation(scope);
        if(!conListToUpdate.isEmpty())
        {
            upsert conListToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC)
    {
    }
}