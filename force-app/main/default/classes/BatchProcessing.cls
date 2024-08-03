public with sharing class BatchProcessing implements Database.Batchable<SObject>, Databse.Stateful {

    Public Integer recordCount=0;


    public List<Account> start(Database.BatchableContext bc)

    {

        // String query='Select Id,Name From Account';

        return [Select Id,Name From Account];
    }
    
    public void execute( Database.BatchableContext bc, List<Account> record)
    {


        for(Account acc:record)
        {
            acc.Name=acc.Name+'Update By Batch Process JOb';
            recordCount=recordCount+1;
            System.debug(recordCount);
        }
        update record;

        }




    public void finish(Database.BatchableContext bc)
    {
        System.debug('Batch Process Completed');
        List<String> addAddress=new List<String>();
        addAddress.add('chhabra.aman26@gmail.com');
        addAddress.add('ajaysethi184@gmail.com');

        EmailService.sendEmail(addAddress, 'Batch Executed', 'Batch Completed Account Updated'+bc.getJobId());

    }
}