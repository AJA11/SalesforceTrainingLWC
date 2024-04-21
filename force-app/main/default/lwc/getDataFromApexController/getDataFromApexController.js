import { LightningElement,wire,api } from 'lwc';
// import getReservationData from '@salesforce/apex/GetRecordDataController.getReservationData';
import {getRecord} from'lightning/uiRecordApi';
import Start_Date__c from '@salesforce/schema/Contact.Name';
import End_Date__c from '@salesforce/schema/Contact.Email';

export default class GetDataFromApexController extends LightningElement 
{

     @api recordId;

    fields=[Start_Date__c,End_Date__c];
    @wire(getRecord,{recordId:'$recordId',fields:['Name','Email']}) getReservation

    // @wire(getReservationData) 
    // getData({error,data})
    // {
    //     if(data)
    //     {
    //         console.log(data)
    //     }
    //     else if(error)
    //     {
    //         console.log(error);
    //     }
    // } 
    
    // // getData;

    // getDataFromApex()
    // {
    //     getReservationData().then(res=>
    //             {        
                    
                    
    //                 console.log(res);
    
    
    //             })
    // }


    // anotherFunction()
    // {
    //     this.getDataFromApex();
    // }

    // connectedCallback()
    // {
        
    //     // console.log(this.getData);

    //     // getReservationData().then(res=>
    //     //     {        console.log(res);


    //     //     })
    // }

}