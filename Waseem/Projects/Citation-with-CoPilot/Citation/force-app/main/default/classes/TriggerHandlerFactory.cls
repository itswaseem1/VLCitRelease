public without sharing class TriggerHandlerFactory
{
    private static Map<SObjectType, ITriggerHandler> registeredInstances = new Map<SObjectType, ITriggerHandler>();
    public static void registerInstance(SObjectType objType, ITriggerHandler srv)
    {
        registeredInstances.put(objType, srv);
    }

    public static ITriggerHandler getInstance(SObjectType objType)
    {
        ITriggerHandler srv = registeredInstances.get(objType);

        return srv;
    }
}