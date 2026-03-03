*** Settings ***
Library                 QWeb
Library                 String
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Send Email Verify Inbox And Open URLs
    [Documentation]    Automates login, sends an email to self with URLs, verifies receipt, opens the URLs, and checks that they loaded.
    [Tags]             testgen
    # 1. Navigate to Gmail login and handle Okta MFA
    GoTo           https://mail.google.com
    VerifyText     Sign in
    TypeText       Email or phone    ${C_EMAIL}
    ClickText      Next

    VerifyText     Connecting to
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In

    VerifyText     Okta Verify
    ClickText      Send Push         timeout=60s   
    VerifyText     Inbox             timeout=15s    

    # 2. Setup Variables for this specific test
    ${RANDOM_STR}=  Generate Random String    6    [LETTERS]
    ${SUBJECT}=     Set Variable    Automated URL Test ${RANDOM_STR}

    # 3. Hit Compose and Send the Email to Yourself
    ClickText      Compose
    VerifyText     New Message       timeout=10s
    TypeText       To                ${C_EMAIL}
    PressKey       To                {ENTER}
    TypeText       Subject           ${SUBJECT}
    TypeText       Message Body      Hello! Please check these links:\n\n1. ${URL_1}\n2. ${URL_2}
    ClickText      Send
    VerifyText     Message sent      timeout=15s

    # 4. Verify the email arrives in the inbox and open it
    ClickText      Inbox             
    ClickText      ${SUBJECT}        timeout=30s              
    VerifyText     Hello! Please check these links            

    ClickText      ${URL_1}          
    SwitchWindow   2                 
    VerifyUrl      ${URL_1}     timeout=10s    
    CloseWindow                      
    SwitchWindow   1                 
    

    ClickText      ${URL_2}          
    SwitchWindow   2                 
    VerifyUrl      ${URL_2}        timeout=10s    
    CloseWindow                      
    SwitchWindow   1                