({
	myAction : function(component, event, helper) {
        
        var getData=component.get("c.getAccountDataAuraComponenList");
        
        
        getData.setCallback(this, function(response){
            
            var state= response.getState();
            
            if(state=='SUCCESS')
            {
                component.set("v.accounts", response.getReturnValue());
            }
            else
            {
                Console.log("Error");
                
            }
        });
        
        $A.enqueueAction(getData);
		
	}
})