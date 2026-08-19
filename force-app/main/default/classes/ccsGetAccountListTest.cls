/**
	 * ccsGetAccountListTest
	 * @description      : Test class for ccsGetAccountList
	 * @author           :
	 * @last modified on :21st Aug 2024
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    21st Aug 2024   Mandeep Singh		CRM-5992
	 */

@isTest
public class ccsGetAccountListTest {
	public static testMethod void getAccounts() {
   
      User u = [Select id from user where profile.name='System Administrator' and IsActive = TRUE Limit 1];
      //create account
      String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
      
      List<Account> testAccounts = new List<Account>();  
      testAccounts.add (new Account(
      RecordTypeID = recordTypeId ,
      FirstName ='Rick',
      LastName ='Blue',
      PersonMailingStreet ='ABC Ave.',
      PersonMailingPostalCode ='12345',
      PersonMailingCity ='SFO',
      PersonEmail ='test@yahoo.com',
      PersonHomePhone ='1234567',
      PersonMobilePhone ='12345678'
      ));
      
      testAccounts.add (new Account(
      RecordTypeID = recordTypeId ,
      FirstName ='TOM',
      LastName ='Apples',
      PersonMailingStreet ='LOM Ave.',
      PersonMailingPostalCode ='123456',
      PersonMailingCity ='SFO',
      PersonEmail ='test1@yahoo.com',
      PersonHomePhone ='12345678',
      PersonMobilePhone ='123456789'
      ));
        
      testAccounts.add (new Account(
      RecordTypeID = recordTypeId ,
      FirstName ='bOB',
      LastName ='MANGOES',
      PersonMailingStreet ='MNP Ave.',
      PersonMailingPostalCode ='012345',
      PersonMailingCity ='SFO',
      PersonEmail ='1test@yahoo.com',
      PersonHomePhone ='11234567',
      PersonMobilePhone ='112345678'
      ));
        
      testAccounts.add (new Account(
      RecordTypeID = recordTypeId ,
      FirstName ='Cob',
      LastName ='Bananas',
      PersonMailingStreet ='XYZ Ave.',
      PersonMailingPostalCode ='12345',
      PersonMailingCity ='SFO',
      PersonEmail ='tEsTme@yahoo.com',
      PersonHomePhone ='122234567',
      PersonMobilePhone ='1222345678'
      ));
        
      insert testAccounts;
        

      List<ccsGetAccountList.methodInputs> inputList = new List<ccsGetAccountList.methodInputs>();
      
      ccsGetAccountList.methodInputs input0 = new ccsGetAccountList.methodInputs();
      
      input0.FirstName = '';
      input0.LastName = 'Blue';
      input0.Phone = '';
      input0.Email = '';
        
      inputList.add(input0);
    
      // case-sensitivity test on First Name
      List<ccsGetAccountList.methodInputs> inputList1 = new List<ccsGetAccountList.methodInputs>();
      ccsGetAccountList.methodInputs input1 = new ccsGetAccountList.methodInputs();
      
      input1.FirstName = 'tom';
      input1.LastName = 'Apples';
      input1.Phone = '';
      input1.Email = '';
        
      inputList1.add(input1);
      
      List<ccsGetAccountList.methodInputs> inputList2 = new List<ccsGetAccountList.methodInputs>();  
      ccsGetAccountList.methodInputs input2 = new ccsGetAccountList.methodInputs();
      
      input2.FirstName = 'Bob';
      input2.LastName = 'Mangoes';
      input2.Phone = '';
      input2.Email = '';
        
      inputList2.add(input2);
      
      // case-sensitivity test on email field
      List<ccsGetAccountList.methodInputs> inputList3 = new List<ccsGetAccountList.methodInputs>();
      ccsGetAccountList.methodInputs input3 = new ccsGetAccountList.methodInputs();
      
      input3.FirstName = '';
      input3.LastName = '';
      input3.Phone = '';
      input3.Email = 'tEsTme@yahoo.com';
        
      inputList3.add(input3);
	          
	  Test.startTest(); 
       
      List<ccsGetAccountList.methodOutputs> outputList = ccsGetAccountList.invokeThisMethod(inputList);
      system.assert(outputList.size()>0);
        
      List<ccsGetAccountList.methodOutputs> output1 = ccsGetAccountList.invokeThisMethod(inputList1);
      system.assertEquals(1,output1.size());
      
      List<ccsGetAccountList.methodOutputs> output2 = ccsGetAccountList.invokeThisMethod(inputList2);
      system.assertEquals(1,output2.size());
        
      List<ccsGetAccountList.methodOutputs> output3 = ccsGetAccountList.invokeThisMethod(inputList3);
      system.assertEquals(1,output3.size());
          
      Test.stopTest();        
    }
}