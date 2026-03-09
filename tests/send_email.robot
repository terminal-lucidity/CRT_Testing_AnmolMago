*** Settings ***
Library         RetryFailed
Library         QWeb
Library         String             
Library         ../resources/EmailHandler.py    
Suite Setup     Open Browser    about:blank    chrome    --guest
Suite Teardown  Close All Browsers

*** Variables ***
${SENDER_EMAIL}         amago.testmail@gmail.com
${RECIPIENT_EMAIL}      amago.testmail@gmail.com

${EMAIL_BODY}           Hello! Please check out this link: <a href="https://docs.copado.com/home/en-us/">Copado Docs</a> and <a href="https://www.google.com/">Google</a>.
${PARTIAL_VERIFY}       Please check out this link

*** Test Cases ***
Assignment 4 Send Verify And Open URLs
    [Documentation]    Sends an email, verifies receipt, and opens all URLs contained inside.
    [Tags]        testgen            test:retry(1)
    
    ${RANDOM_STR}=     Generate Random String    6    [LETTERS]
    ${EMAIL_SUBJECT}=  Set Variable    Copado CRT Assignment 4 - Test ${RANDOM_STR}
    Send Gmail    ${SENDER_EMAIL}    ${RECIPIENT_EMAIL}    ${EMAIL_SUBJECT}    ${EMAIL_BODY}
    ${urls}=      Verify Email And Extract Urls    ${RECIPIENT_EMAIL}    ${EMAIL_SUBJECT}    ${PARTIAL_VERIFY}
    

    Log To Console    Found URLs: ${urls}
    
    FOR    ${url}    IN    @{urls}
        GoTo         ${url}
        VerifyUrl    ${url}    timeout=10s 
        Sleep        2s
    END