import { LightningElement } from 'lwc';
import signInTemplate from './signInTemplate.html';
import signUpTemplate from './signUpTemplate.html';
import defaultTemplate from './multipleTemplateRender.html';

export default class MultipleTemplateRender extends LightningElement 

{

    selected;

    render()
    {
        return this.selected ==='Sign Up' ? signUpTemplate:
        this.selected === 'Sign In' ?signInTemplate:defaultTemplate

    }


    handleClick(event)
    {
        this.selected=event.target.label;

        console.log(this.selected);
    }

    sumbitHandler(event)
    {
        if(event.target.label=='Sign In')
        {
            console.log('Sign In Sucesfully');
        }
        else if(event.target.label=='Sign UP')
        {
            console.log('Sign Up Sucessfully');
        }
        else
        {
            console.log('Pressed Back Button')
        }

    }
}

