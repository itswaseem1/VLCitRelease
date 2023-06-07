public interface IProcessor {
	boolean hasCandidates(IProcessorFactory factory);
	void processCandidates();
}