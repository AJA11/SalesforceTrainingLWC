public with sharing class GetRecordDataController 

{
  
    @AuraEnabled(Cacheable=true)
    public static List<Reservation__c> getReservationData()
    {
        List<Reservation__c> getRecord=[SELECT  Id,Start_Date__c,Name,End_Date__c ,Contact__r.Id FROM Reservation__c LIMIT 10];


        return getRecord;

    }



    @AuraEnabled(Cacheable=true)
    public static List<Account> getAccountData()
    {
        List<Account> getRecord=[SELECT  Id,Name,Phone FROM Account];


        return getRecord;

    }



    @AuraEnabled
    public static void databaseInserMethod()
    {

        try
        {

            
            List<Account> addData=new List<Account>();
            
            
            for(Integer i=0; i<12; i++)
            {
                Account getField=new Account();

                getField.Name='Testing ' +i;
                getField.Phone='222-2222-222' +i;
                getField.YearStarted='201'+i;

                addData.add(getField);
            }
            
      

        Database.SaveResult [] getListOfMessage =Database.insert(addData,false);
        for(Database.SaveResult getMessage:getListOfMessage)
        {
            System.debug(getMessage);

            if(getMessage.isSuccess())
            {
                System.debug(getMessage);
                System.debug('Data is successfully inserted');
            }
            else
            {
                System.debug('Error Has come while inserting data');
            for(Database.Error getError : getMessage.getErrors())
                {
                    System.debug('Error has come'+ getError.getFields());
                    System.debug('Error has come'+ getError.getMessage());
            }
        }
    }
        
    }
    catch(Exception ex)
    {
        throw new AuraHandledException(ex.getMessage());
    }


    }

    
    @AuraEnabled
    public static void insertAccountData(WrapperClass getData)
    {

        try
        {
        Account getField=new Account();

        getField.Name=getData.accountName;
        getField.Phone=getData.phoneNumber;
        
            insert getField;
    }
    catch(Exception ex)
    {
        throw new AuraHandledException(ex.getMessage());
    }


    }


     
    @AuraEnabled
    public static void updateAccountData(WrapperClass getData)
    {

        // List<Account> getAccount=[Select Id, Name,Phone From Account WHERE Id=:getData.accountId];
        try
        {
        // Account getField=new Account();

        Account newAcc=new Account();
        newAcc.Id=getData.AccountId;
        newAcc.Name=getData.accountName;
        newAcc.Phone=getData.phoneNumber;
        
        update newAcc;
    }
    catch(Exception ex)
    {
        throw new AuraHandledException(ex.getMessage());
    }


    }


    public static void undeleteMethod()
    {
        
    }
    public class WrapperClass
    {

        @AuraEnabled
        public string accountId {get;set;}
        @AuraEnabled
        public string accountName {get;set;}

        @AuraEnabled
        public string phoneNumber{get;set;}

        @AuraEnabled
        public string yearStarted{get;set;}


    }
}



