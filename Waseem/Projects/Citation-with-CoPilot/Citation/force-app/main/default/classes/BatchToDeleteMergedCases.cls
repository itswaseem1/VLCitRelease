/**
* @File Name          : BatchToDeleteMergedCases.cls
* @Description        :
* @Author             : Maanas
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 3/25/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     3/25/2021      Initial Version
**/
public class BatchToDeleteMergedCases implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('Select Id FROM Case WHERE Status = \'Merged Closed\'');
    }
    
    
    public void execute(Database.BatchableContext bc, List<Case> scope){
        
        try{
            delete scope;
        }catch( Exception  error ){
            system.debug(error.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        system.debug('after finish logic to send error emails');
    }
}