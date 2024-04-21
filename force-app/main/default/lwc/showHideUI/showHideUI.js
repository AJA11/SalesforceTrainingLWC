import { LightningElement } from 'lwc';

export default class ShowHideUI extends LightningElement 

{
    showData=false;
    showDataPart=true;
    handleData(event)
    {
        this.showData=event.target.checked

        if(this.showData==false)
        {
            this.showDataPart=true;
        }
        else
        {
            this.showDataPart=false;
        }
    }
}