public with sharing class TaskAfterInsertFactory implements ITaskAfterInsertFactory {
	
	private static Set<Type> processorTypes = new Set<Type>();
	List<Task> newTasks = new List<Task>();
	Map<Id, Task> newTasksMap = new Map<Id, Task>();
	
	public List<Task> getNewTasks() {
		return newTasks;
	}
	public Map<Id, Task> getNewTasksMap() {
		return newTasksMap;
	}
	
	// Add the new Tasks to be processed to the lists, add all ITaskAfterInsertProcessor types to the internal array
	// which need processing after a task insert.
	public TaskAfterInsertFactory(final List<Task> newObjects, final Map<Id, Task> newObjectsMap) {
		newTasks = newObjects;
		newTasksMap = newObjectsMap;
		processorTypes.Add(Type.forName('CIT_TaskNobleLeadIntegration'));
		system.debug(processorTypes);
	}
	
	// For each processor type in the factory array, create a new instance of that
	// processor type, then pass in the factory reference, which contians the list of
	// tasks that need processing, if the processor needs to perform actions on some of the
	// tasks, it will return true and be added to the list of processors toProcess.
	public List<IProcessor> getProcessors() {
		List<IProcessor> toProcess = new List<IProcessor>();
		for (Type processorType : processorTypes) {
			IProcessor processor = (IProcessor)processorType.newInstance();
			if (processor instanceof ITaskAfterInsertProcessor) {							
				System.debug(processor);				
				if (processor.hasCandidates((IProcessorFactory)this)) {
					toProcess.Add(processor);
				}
			}
		}
		System.debug(toProcess);
		return toProcess;
	}
}