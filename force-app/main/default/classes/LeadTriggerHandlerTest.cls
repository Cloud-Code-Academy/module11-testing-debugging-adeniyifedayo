@isTest
public with sharing class LeadTriggerHandlerTest {
    @isTest
    public static void LeadTriggerHandler_handleTitleNormalization() {
        List <Lead> testLeads = new List <Lead> ();
        Lead testLead1 = new Lead(FirstName = 'Jane', LastName = 'Doe', Company = 'Cloud Code', Title = 'vp');
        Lead testLead2 = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Cloud Code', Title = 'head of department');
        Lead testLead3 = new Lead(FirstName = 'Jill', LastName = 'Doe', Company = 'Cloud Code', Title = 'chief');
        Lead testLead4 = new Lead(FirstName = 'Jim', LastName = 'Doe', Company = 'Cloud Code', Title = 'assistant finance officer');

        testLeads.add(testLead1);
        testLeads.add(testLead2);
        testLeads.add(testLead3);
        testLeads.add(testLead4);

        Test.startTest();
        insert testLeads;
        Test.stopTest();
        
        List <Lead> insertedTestLeads = [SELECT Id, Name, Title FROM Lead WHERE Id IN :testLeads];
        Set <String> leadTitles = new Set <String> ();
        for (Lead ld : insertedTestLeads){
            leadTitles.add(ld.Title);
        }

        Assert.areEqual(true, leadTitles.contains('Vice President'), 'Title should be Vice President');
        Assert.areEqual(true, leadTitles.contains('Manager'), 'Title should be Manager');
        Assert.areEqual(true, leadTitles.contains('Executive'), 'Title should be Executive');
        Assert.areEqual(true, leadTitles.contains('Assistant'), 'Title should be Assistant');
    }

    @isTest
    public static void LeadTriggerHandler_handleAutoLeadScoring(){
        List <Lead> testLeadsWithScores = new List <Lead> ();
        Lead testLead5 = new Lead(FirstName = 'Jane', LastName = 'Doe', Company = 'Cloud Code', LeadSource = 'Website', Phone = '6478355589', Email = 'jane.doe@cloudcode.com', Industry = 'Technology', Title = 'vp');
        Lead testLead6 = new Lead(FirstName = 'Jill', LastName = 'Doe', Company = 'Cloud Code', LeadSource = 'Website', Phone = '6478355589', Email = 'jill.doe@cloudcode.com', Title = 'vp');
        Lead testLead7 = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Cloud Code', LeadSource = 'Website', Email = 'john.doe@cloudcode.com', Title = 'vp');
        Lead testLead8 = new Lead(FirstName = 'Jim', LastName = 'Doe', Company = 'Cloud Code', Phone = '6478355589', Title = 'vp');

        testLeadsWithScores.add(testLead5);
        testLeadsWithScores.add(testLead6);
        testLeadsWithScores.add(testLead7);
        testLeadsWithScores.add(testLead8);

        Test.startTest();
        insert testLeadsWithScores;
        Test.stopTest();

        List <Lead> insertedTestLeads = [SELECT Id, Lead_Score__c FROM Lead WHERE Id IN :testLeadsWithScores];
        Set <Decimal> leadScores = new Set <Decimal> ();
        for (Lead ld : insertedTestLeads){
            leadScores.add(ld.Lead_Score__c);
        }

        Assert.areEqual(true, leadScores.contains(18), 'Score should be 18');
        Assert.areEqual(true, leadScores.contains(8), 'Score should be 8');
        Assert.areEqual(true, leadScores.contains(3), 'Score should be 3');
        Assert.areEqual(true, leadScores.contains(5), 'Score should be 5');
    }

    @isTest
    public static void LeadTriggerHandler_handleLeadAutoConvert_matchingContact(){
        List <Account> accountList = new List <Account> ();
        Account acc = new Account (Name = 'Cloud Code');
        accountList.add(acc);
        insert accountList;

        List <Account> insertedacc = [SELECT Id, Name FROM Account WHERE Id IN :accountList];
        String accId = insertedacc[0].Id;

        List <Contact> contactList = new List <Contact> ();
        Contact contact = new Contact (FirstName = 'John', LastName = 'Doe', Email = 'john.doe@cloudcode.com', AccountId = accId);

        contactList.add(contact);
        insert contactList;

        List <Contact> insertedContact = [SELECT Id, Email FROM Contact WHERE Id IN :contactList];
        System.debug(insertedContact);

        String insertedContactId = insertedContact[0].Id;
        String insertedContactEmail = insertedContact[0].Email;

        List <Lead> testLeadsList = new List <Lead> ();
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Cloud Code', Email = 'john.doe@cloudcode.com', Title = 'vp');
        testLeadsList.add(testLead);

        Test.startTest();
        insert testLeadsList;
        Test.stopTest();

        List <Lead> insertedTestLeads = [SELECT Id, ConvertedContactId, IsConverted, Email FROM Lead WHERE Id IN :testLeadsList];
        System.debug(insertedTestLeads);

        Boolean converted = insertedTestLeads[0].IsConverted;
        String contactId = insertedTestLeads[0].ConvertedContactId;
        String leademail = insertedTestLeads[0].Email;
    
        Assert.areEqual(insertedContactId, contactId, 'Contact IDs should match');
        Assert.isTrue(converted, 'Lead Converted should be True');
        Assert.areEqual(insertedContactEmail, leademail, 'Contact Email and Lead Email should match');
    }
    @isTest
    public static void LeadTriggerHandler_handleLeadAutoConvert_noMatchingContact(){
        List <Lead> testLeadsList = new List <Lead> ();
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Cloud Code', Email = 'john.doe@cloudcode.com', Title = 'vp');
        testLeadsList.add(testLead);

        Test.startTest();
        insert testLeadsList;
        Test.stopTest();

        List <Lead> insertedTestLeads = [SELECT Id, ConvertedContactId, IsConverted, Email FROM Lead WHERE Id IN :testLeadsList];
        System.debug(insertedTestLeads);

        Boolean converted = insertedTestLeads[0].IsConverted;
        String contactId = insertedTestLeads[0].ConvertedContactId;

        Assert.isNull(contactId, 'Contact ID should be null as Lead should not auto convert');
        Assert.isFalse(converted, 'Should be null as Lead should not auto convert');
    }
}