public interface ITaskAfterInsertFactory extends IProcessorFactory {
	List<Task> getNewTasks();
	Map<Id, Task> getNewTasksMap();
}