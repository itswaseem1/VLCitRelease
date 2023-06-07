global class CreateQuoteForRenOpp_Batch implements Database.Batchable<SObject>,Database.Stateful {

    private String query;
	
	global CreateQuoteForRenOpp_Batch(String Qry){
		query = Qry;
	}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        
                List<Opportunity> oppties = new List<Opportunity>();        
                for(Opportunity opp: scope){
                    oppties.add(opp);
                }
        	TriggerOpportunityHandler.createQuotes(oppties);
                
    }
    
    global void finish(Database.BatchableContext bc){
    }
}