/*
*   Code for maintaining some control over storage, namely the deletion or 'archiving'
*   of records as they are no longer needed.
*
*   There are potentially many record types that will need processing, and each may have
*   its own rules around retention periods or how to archive. Hence, this service is written
*   to construct a list of IDataCleaners that each know how to handle one object type, along with 
*   some basic config like retention period or whether it has been deactivated etc.
*
*   This will allow us to add more such tasks without changing this service too much.
*/
public without sharing class DataCleanService implements IDataCleaner
{
    /*
    *   Inner class used to run this service as an async job. Not exposed as public
    *   as the intent is to keep the mechanism private and easily changeable if needed.
    *
    *   We chain queaueables rather than run a batch, as it is some what
    *   awkward to work out how many executes to run up front, especially 
    *   as we want to support extra jobs being added as a plugin etc. 
    *
    *   Equally, batches are a limited resource (5/100) whereas queueables are not.
    *
    *   This queuable will execute a cleanup, check for more work and requeue itself if needed.
    */
    class AsyncRunner implements Queueable
    {
        private IDataCleaner cleaner;

        AsyncRunner(IDataCleaner cleaner)
        {
            this.cleaner = cleaner;
        }

        public void execute(QueueableContext ctx)
        {
            cleaner.cleanUp();
            if(cleaner.hasMore())
            {
                System.enqueueJob(this);
            }
        }
    } 

    /*
    *   Whilst the service can be ran sync by calling the methods directly, it
    *   is likely that the nature of mass archive/delete requires async jobs and 
    *   many executions.
    *
    *   This method provides that feature, callers can call this and not worry about how to run it. 
    *
    *   NB this method will look at the custom metadata and load in the cleanup classes based on
    *   that, as well as the information about retention periods and such that are needed by the implementation classes.
    *   This allows for new cleanup/archiving to be added and controlled by config, with no great change
    *   to this service code.  
    */
    public static void runAsync()
    {
        List<Clean_Archive__mdt> configs = [SELECT ClassName__c, Retention_Period__c, Chunk_Size__c
                                            FROM Clean_Archive__mdt
                                            WHERE Active__c = true];

        runAsync(configs);
    }

    /*
    *   This method exists as testing custom metedata is a pain, you cannot create it during a test making
    *   testing any selection hard.  NB need to look at the metadata deployment classes as they may allow
    *   testability of a selector class; although the existence of such data might interfere with other tests 
    *   (depending on how it works).
    *   Put this here for now to isolate the 1 line that is hard to test, even though it uses @testVisible :(
    */
    @testVisible
    private static void runAsync(List<Clean_Archive__mdt> configs)
    {
        if(configs.isEmpty())
            return;

        List<IDataCleaner> cleanupTasks = new List<IDataCleaner>();
        for(Clean_Archive__mdt config :configs)
        {
            AbstractCleaner cleaner = (AbstractCleaner)Type.forName(config.ClassName__c).newInstance();
            cleaner.setConfig(config);

            cleanupTasks.add(cleaner);
        }

        runAsync(cleanupTasks);
    }

    /*
    *   This method is the one that kicks off the chain of cleaners in a queueable.
    *   Could be changed to use another mechansim in future.
    *
    *   Making this method public might be useful to allow for other IDataClean impls to be used
    *   instead of the ones loaded via config.
    *
    *   We wrap the list of cleanup tasks in an instance of this service, and the service
    *   acts as an orchestrator of all the tasks that the queueable is calling.  It is this class
    *   that knows how to check the state of each task and flip to the next one when the current one has finished.
    */
    private static void runAsync(List<IDataCleaner> cleanupTasks)
    {
        IDataCleaner srv = new DataCleanService(cleanupTasks);
        System.enqueueJob(new AsyncRunner(srv));
    }

    // [Instance members]
    private List<IDataCleaner> cleanupTasks;

    public DataCleanService(List<IDataCleaner> cleanupTasks)
    {
        this.cleanupTasks = cleanupTasks;
    }

    public void cleanUp()
    {
        if(cleanupTasks.isEmpty())
            return;

        IDataCleaner current = cleanupTasks.get(0);
        current.cleanUp();
    }

    public Boolean hasMore()
    {
        if(cleanupTasks.isEmpty())
            return false;

        IDataCleaner current = cleanupTasks.get(0);
        if(current.hasMore())
            return true;
        
        cleanupTasks.remove(0);
        if(cleanupTasks.isEmpty())
            return false;
        else
            return hasMore();
    }

    public abstract class AbstractCleaner implements IDataCleaner 
    {
        private Clean_Archive__mdt config;

        public void setConfig(Clean_Archive__mdt config)
        {
            this.config = config;
        }

        protected Integer getLiveRetentionPeriod()
        {
            return config.Retention_Period__c == null ? 36500 : Integer.valueOF(config.Retention_Period__c);
        }

        protected Integer getChunkSize()
        {
            return config.Chunk_Size__c == null ? 200 : Integer.valueOF(config.Chunk_Size__c);
        }

        public abstract void cleanUp();
        public abstract Boolean hasMore();
    }

    /*
    *   Implementation for ffbc__Jobs.
    *   
    *   NB other classes do not have to be inner classes like this, but if they are to be loaded via config
    *   then they must extend AbstractCleaner
    */ 
    public class JobCleaner extends AbstractCleaner
    {
        public override void cleanUp()
        {
            List<ffbc__Job__c> objs = getRecords(getChunkSize());
            delete objs;
        }

        public override Boolean hasMore()
        {
            List<ffbc__Job__c> objs = getRecords(1);
            return objs.size() > 0;
        }

        private List<ffbc__Job__c> getRecords(Integer maxRecords)
        {
            Date retentionDate = Date.today() - getLiveRetentionPeriod();
            return [SELECT Id FROM ffbc__Job__c WHERE lastModifiedDate < :retentionDate LIMIT :maxRecords];
        }
    }
}