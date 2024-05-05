import { LightningElement,api } from 'lwc';

export default class ReceviedMessageInChildComponent extends LightningElement 

{
    @api messagae;
    @api className;


    get  classNameFromParent()
    {
        console.log (this.className ? 'alert'+this.className: 'alert');

            return this.className ? 'alert '+this.className: 'alert'

    }



}