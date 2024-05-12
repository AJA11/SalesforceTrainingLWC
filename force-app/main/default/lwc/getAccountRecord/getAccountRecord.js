import { LightningElement,wire } from 'lwc';
import getAccountData from '@salesforce/apex/GetRecordDataController.getAccountData';
import insertAccountData from '@salesforce/apex/GetRecordDataController.insertAccountData';
import { refreshApex } from '@salesforce/apex';
export default class GetAccountRecord extends LightningElement 

{

    accountData;

    getDataFromAccount;
   @wire(getAccountData) 
    getData(result)
    {
        this.accountData=result;
        const{error,data}=result;
        if(data)
        {
            this.getDataFromAccount=data;
            
        }
        else if(error)
        {
            console.log(error);
        }
    } 
    

    inserRecord()
    {
        let paremeterObject=
        
        {
            accountName:this.template.querySelector('lightning-input[data-field="nameValue"').value,
            phoneNumber:this.template.querySelector('lightning-input[data-field="phoneValue"').value,
        }
       console.log(paremeterObject);
       console.log(paremeterObject.accountName);

        insertAccountData(
            {
                getData:paremeterObject
            }).then(res=>
                {                   
                    
                    
                    console.log(res);

                    refreshApex(this.accountData);
                })

    }
}