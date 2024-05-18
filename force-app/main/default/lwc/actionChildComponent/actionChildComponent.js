import { LightningElement,api } from 'lwc';

export default class ActionChildComponent extends LightningElement 

{
    @api percentage;

    
    get getStyle()
    {

        console.log(this.percentage);

        return 'width:' +this.percentage +'%';


    }
}