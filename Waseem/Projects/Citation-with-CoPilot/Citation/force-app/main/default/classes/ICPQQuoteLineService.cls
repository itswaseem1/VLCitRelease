public interface ICPQQuoteLineService extends IDomainService{
	/*
    *   Handles the check to see whether someone should be
    *   making a call to RollUp the child quotelines.
    */
    void rollUpAmountToParentLine(Set<ID> ids);
}