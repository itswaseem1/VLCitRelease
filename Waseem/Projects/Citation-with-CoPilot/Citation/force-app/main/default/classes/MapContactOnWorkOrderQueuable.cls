public with sharing class MapContactOnWorkOrderQueuable implements Queueable {
    private List<WorkOrder> newWOList = new List<WorkOrder>();
    private List<WorkOrder> contactOnWorkOrderList = new List<WorkOrder>();
    
    public MapContactOnWorkOrderQueuable(List<WorkOrder> newWOList){
        this.newWOList = newWOList;
    }

    	public void execute(QueueableContext context) {
        contactOnWorkOrderList =    MapContactOnWorkOrderQueuableHandler.populateContactOnWO(newWOList) ;  
            if (null != contactOnWorkOrderList && contactOnWorkOrderList.size() > 0 &&   Schema.sObjectType.WorkOrder.isUpdateable()) {
            	update contactOnWorkOrderList;
            }
    }

}