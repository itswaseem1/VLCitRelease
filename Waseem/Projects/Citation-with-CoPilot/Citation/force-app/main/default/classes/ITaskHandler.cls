public interface ITaskHandler {
	ITaskHandler getInstance();
	void setFactory(IProcessorFactory factory);
	IProcessorFactory getFactory();
	void handle();
}