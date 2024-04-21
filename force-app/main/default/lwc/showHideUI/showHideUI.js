import { LightningElement,api} from 'lwc';

export default class ShowHideUI extends LightningElement 

{
    @api showData=false;
    showDataPart=true;

   @api  handleData(event)
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