({
	doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var accountid = myPageRef.state.c__accountid;
        
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
        "recordId": accountid
    	});
    	navEvt.fire();
        
        var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        "title": "ERROR",
        "message": "The 'Banking ID' is required in order to complete a new Money Chat.",
        "type" : "Error"
        
    });
    toastEvent.fire();
    
    }
})