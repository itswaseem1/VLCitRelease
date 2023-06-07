public with sharing class TriggerTaskHandler implements ITaskHandler {

	public IProcessorFactory factory { get; set; }
	
	public void setFactory(IProcessorFactory factory) {
		this.factory = factory;
	}
	public IProcessorFactory getFactory() {
		return factory;
	}
	
	private static TriggerTaskHandler instance;	
    public static ITaskHandler getInstance() {
    	if (instance == null) {
        	instance = new TriggerTaskHandler();
    	}
   		return instance;
	}
	
	// Get all the processor objects from the factory that need to process
	// tasks, then call each processor to process its tasks.
	public void handle() {
		if (factory != null) {
			List<IProcessor> processors = factory.getProcessors();
			for (IProcessor processor : processors) {
				processor.processCandidates();
			}
		}
	}
}