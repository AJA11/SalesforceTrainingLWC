public class HttpRequestRestAPIController {
    
    
    public static void testRestAPIGet()
    {
        Http http=new Http();
        HttpRequest requestApi=new HttpRequest();
        requestApi.setEndPoint('https://th-apex-http-callout.herokuapp.com');
        requestApi.setMethod('GET');
        
        HttpResponse response=http.send(requestApi);
        
        if(response.getStatusCode()==200)
        {
            System.debug(response.getBody());
            
            
           JSON2Apex getResult= (JSON2Apex) System.JSON.deserialize(response.getBody(), JSON2Apex.class);
            Map<String,Object>result=(Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            
            System.debug(result);
            System.debug(getResult);
            System.debug(getResult.trailhead);
            
                        System.debug(result.get('trailhead'));

        }
        
    }
 
    
    
    public static void testRestAPIPost()
    {
        Http http=new Http();
        HttpRequest requestApi=new HttpRequest();
        requestApi.setEndPoint('https://th-apex-http-callout.herokuapp.com/animals');
        requestApi.setMethod('POST');
        requestApi.setHeader('Content-Type', 'application/json; charset=UTF-8');
        requestApi.setBody('{"name":"Ajay"}');
        
                             
        HttpResponse response=http.send(requestApi);
        if(response.getStatusCode()==201)
        {
            System.debug(response.getBody());
        }
        
    }
 
    public class JSON2Apex {

	public String trailhead;

	
	
}

}