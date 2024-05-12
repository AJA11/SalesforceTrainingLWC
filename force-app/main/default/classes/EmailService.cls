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
}