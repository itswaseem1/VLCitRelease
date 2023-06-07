public class Triggerc2gInvoiceHandler {
    public static void CheckDimension(list<c2g__codaInvoice__c> invoiceList) {
        list<c2g__codaDimension1__c> dim1List = [select id from c2g__codaDimension1__c where name = 'CP102 - Corporate'] ;
        if(dim1List.size() >0) {
            for(c2g__codaInvoice__c invoice : invoiceList) {
                if(invoice.c2g__Dimension1__c == null) {
                    invoice.c2g__Dimension1__c = dim1List[0].id ;
                }
            }
        }

    }
}