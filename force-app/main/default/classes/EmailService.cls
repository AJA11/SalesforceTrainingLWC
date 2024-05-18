public with sharing class EmailService {
   

    public static void sendEmail(List<String> address,String subject,String body)
    
    
    {

        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();

        // String[] toAddresses= new String[]{address};

        mail.setToAddresses(address);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        Messaging.SendEmailResult[] results= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

        System.debug(results);



    }


    public static void emailTriggerHelper(Integer recordCount)
    {
        List<String> address=new List<String>();
        address.add('ajaysethi184@gmail.com');
        address.add('chhabra.aman26@gmail.com');
        address.add('luckyindorkar.sfdc@gmail.com');
    
            String subject='Trigger Testing';
            String body='Total Account Inserted '+ recordCount;
            sendEmail(address, subject, body);
    }

    public static void updateAccount(List<Account> newList,Map<Id,Account> oldMap)
    {
        List<Account> accToUpdate=new List<Account>();

        for(Account acc:newList)
        {
            Account ac=new Account(id=acc.id);

            ac.Description='Testing Recursion';
            accToUpdate.add(ac);

        }
    
        if(!accToUpdate.isEmpty())
        {
            update accToUpdate;
        }
    
    
    
    
    }
}