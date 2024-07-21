public with sharing class DynamicQueryController {
   public static void getDynamicFieldAndQuery()
   {
    String objectName='Room__c';

    Set<String> getFieldData=getAlldField(objectName);

        String query='Select '+ String.join(getFieldData,',')+ ' FROM '+objectName;

            List<SObject> getQuery=Database.query(query);
           // List<Room__c> getQueryHotel=Database.query(query);


for(SObject getData:getQuery)
{
    Room__c getRoom= (Room__c)getData;//Specially to get RelationShip Fields
    
    System.debug(getRoom.Hotel__r.Name);
}
   }



   public static Set<String> getAlldField(String objectName)
   {
    Map<String,Schema.SObjectField> getFieldMap=schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        System.debug(getFieldMap.keySet());

Set<String> allFields=new Set<String>(getFieldMap.keySet());


System.debug(allFields);
allFields.add('Hotel__r.Name');
return allFields;

   }
}