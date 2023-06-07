/*
*   Implement this interface to handle the deletion/archiving of a specific 
*   type of record.  The running is dealt with by DataCleanService.
*   
*   NB the service is currently written to handle loadin in these instances via
*   the Clean_Archive_mdt custom metadata.  any implementation that wishes to make
*   use of that must extend DataCleanService.AbstractCleaner rather than directly
*   implement this. The methods on this interface will need implementing, but the 
*   base class handles the config side etc. 
*/
public interface IDataCleaner
{
    /*
    *   Delete or archive some records as appropriate.
    *   This method will deal with what it can in 1 go, 
    *   and is meant to be used in conjunction with hasMore()
    *   to requeue etc, not unlike an iterator, but which runs async.
    */
    void cleanUp();

    /*
    *   Returns whether there is more cleanup to do.
    */
    Boolean hasMore();
}