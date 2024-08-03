public with sharing class ToExecuteQueable {
   
    List<Account> getAccount=[Select Id,Name FROM Account];

    QueableClassController updateJob=  new QueableClassController(getAccount);

    Id jobId=System.enqueueJob(updateJob);
}