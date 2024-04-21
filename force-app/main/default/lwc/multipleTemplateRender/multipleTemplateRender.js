import { LightningElement } from 'lwc';
import signInTemplate from './signInTemplate.html';
import signUpTemplate from './signUpTemplate.html';
import defaultTemplate from './multipleTemplateRender.html';

export default class MultipleTemplateRender extends LightningElement 

{

    selected;
    firstName;
    password;
    emailValue;

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
    getFirstName(event)
    {
        this.firstName=event.target.value;
        console.log(this.firstName);

    }
    getPassowrd(event)
    {
        this.password=event.target.value;
    }
    getEmail(event)
    {
        this.emailValue=event.target.value;
    }
    sumbitHandler(event)
    {
        if(event.target.label=='Sign In')
        {
            this.password=this.template.querySelector('lightning-input[data-field="passwordValue"').value
            this.emailValue=this.template.querySelector('lightning-input[data-field="emailValue"').value

            console.log('Sign In Sucesfully');
            console.log( this.password);
            console.log( this.emailValue);


        }
        else if(event.target.label=='Sign UP')
        {
            console.log('Sign Up Sucessfully');
            console.log(this.firstName);
            console.log(this.password);
            console.log(this.emailValue);


        }
        else
        {
            console.log('Pressed Back Button')
        }

    }
}

