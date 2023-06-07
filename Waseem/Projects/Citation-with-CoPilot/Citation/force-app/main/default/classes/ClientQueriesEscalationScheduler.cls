public class ClientQueriesEscalationScheduler  Implements Schedulable {
    public void execute(SchedulableContext sc)
    {
        Database.executeBatch(new queriesEscalationBatch(), 200);
    }
}