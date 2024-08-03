public with sharing class SchedulerClass implements Schedulable {
    public void execute(SchedulableContext sc)
    {
        BatchProcessing process=new BatchProcessing();
        DataBase.executeBatch(process);
    }

//     0 0 12 * * ?: Every day at noon (12:00 PM)
// 0 0 1 1 * ?: At 1:00 AM on the first day of every month
// 0 0 0 25 12 ?: At midnight on December 25th
}