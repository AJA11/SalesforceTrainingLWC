@RestResource(urlMapping='/NewAccountCreation/*')

global with sharing class CreateRestResourceAPI {
    
    @HttpGet
    global static String createAccount() 
    {

        return 'Api Hit Successfully';

    }
}