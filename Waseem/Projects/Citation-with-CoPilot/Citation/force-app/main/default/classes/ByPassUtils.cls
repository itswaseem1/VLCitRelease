public class ByPassUtils {

    public static Map<String,Boolean> triggerNameBypassed = new Map<String,Boolean>();

    public static void ByPass(String triggerName){
        triggerNameBypassed.put(triggerName,true);
    }

    public static void UndoByPass(String triggerName){
        triggerNameBypassed.put(triggerName,false);
    }

    public static Boolean isByPassed(String triggerName){
        return triggerNameBypassed.containsKey(triggerName) && triggerNameBypassed.get(triggerName);
    }
}