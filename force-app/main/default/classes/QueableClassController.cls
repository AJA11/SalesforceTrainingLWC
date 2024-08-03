public with sharing class QueableClassController implements Queueable {
   
    private List<Account> getAccount;

    
    public  QueableClassController(List<Account> record)
    {
        this.getAccount=record;
    }

    public void execute(QueueableContext context)
    {
        for(Account a:this.getAccount)
        {
            a.Name=a.Name+' '+'Update By Queable';
        }
        update this.getAccount;
    }

}