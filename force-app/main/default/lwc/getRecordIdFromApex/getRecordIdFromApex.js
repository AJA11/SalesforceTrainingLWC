import { LightningElement,wire } from 'lwc';
import getReservationData from '@salesforce/apex/GetRecordDataController.getReservationData';

export default class GetRecordIdFromApex extends LightningElement 


{

    // getData=false;

    // getDataFromApex()
    // {
    //     this.getData=true;
    // }
    @wire(getReservationData) getData;
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
}