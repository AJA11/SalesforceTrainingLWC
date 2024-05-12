trigger AccountLevelTrigger on Account (before insert,before update,after insert,after update,before delete) 


{


    if(Trigger.isInsert)
    {

        Integer recordCount=Trigger.new.size();
        List<String> address=new List<String>();
    address.add('ajaysethi184@gmail.com');
    address.add('chhabra.aman26@gmail.com');
    address.add('luckyindorkar.sfdc@gmail.com');

        String subject='Trigger Testing';
        String body='Total Account Inserted '+ recordCount;
        EmailService.sendEmail(address, subject, body);
     

        
    }

    // if(Trigger.isDelete)
    // {
    //     for(Account acc:Trigger.old)
    //     {
    //         if(acc.AccountNumber!=null)
    //         {
    //             acc.addError('You Can Not delete value with account number');
    //         }
    //     }

    // }

    // if(Trigger.isBefore && Trigger.isInsert)
    // {

    //     System.debug('Before Insert Trigger');

    //     System.debug(Trigger.new);
    //     System.debug(Trigger.newMap);

    //     System.debug(Trigger.operationType);

        
    // }

    // if(Trigger.isUpdate)
    // {
    //     if(Trigger.isBefore)
    //     {
    //         System.debug('before Update');
    //         System.debug(Trigger.operationType);

    //         for(Account acc:Trigger.new)
    //         {
    //             if(acc.AnnualRevenue==null && acc.Industry=='Agriculture')
    //             {
    //                 acc.addError('Annual Revenue Can not be null For Agriculute');
    //             }
    //         }

    //     }
        
    //     if(Trigger.isAfter)
    //     {
    //         System.debug('After Update');
    //     }

    //     System.debug(Trigger.new);
    //     System.debug(Trigger.old);

    //     System.debug(Trigger.oldMap);
    //     System.debug(Trigger.newMap);

    //     System.debug(Trigger.operationType);


    // }

}