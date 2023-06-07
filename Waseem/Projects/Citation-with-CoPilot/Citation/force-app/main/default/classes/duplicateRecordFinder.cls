public with sharing class duplicateRecordFinder {
    public duplicateRecordFinder() {

    }

    public static list<contact> findduplicateContacts(list<contact> ctlist){
        list<contact>       dupContacts = new list<contact>();
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(ctList);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        sobject sObc = matchRecord.getRecord();
                        contact opc = (contact)sObc;
                        dupContacts.add(opc);
                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                    }
                }
            }
        }
        return dupContacts;
    }

    public static list<lead> findduplicateLeads(list<lead> ldlist){
        list<lead>       dupLeads = new list<lead>();
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(ldlist);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        sobject sObc = matchRecord.getRecord();
                        lead opc = (lead)sObc;
                        dupLeads.add(opc);
                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                    }
                }
            }
        }
        return dupLeads;
    }

}