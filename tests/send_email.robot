*** Settings ***
Library                 QWeb
Library                 String           # Required to generate a unique string for the subject
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Send Email Verify Inbox And Open URLs
    [Documentation]    Automates login, sends an email to self with URLs, verifies receipt, and opens the URLs.

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
    ${URL_1}=       Set Variable    https://docs.copado.com
    ${URL_2}=       Set Variable    https://robotframework.org

    # 3. Hit Compose and Send the Email to Yourself
    ClickText      Compose
    VerifyText     New Message       timeout=10s
    TypeText       To                ${C_EMAIL}               # Sending to self so it lands in the current inbox
    PressKey       To                {ENTER}
    TypeText       Subject           ${SUBJECT}
    TypeText       Message Body      Hello! Please check these links:\n\n1. ${URL_1}\n2. ${URL_2}
    ClickText      Send
    VerifyText     Message sent      timeout=15s

    # 4. Verify the email arrives in the inbox and open it
    ClickText      Inbox             # Clicks the Inbox tab to refresh/ensure we are viewing the incoming mail
    ClickText      ${SUBJECT}        timeout=30s              # Waits up to 30s for the email to arrive, then opens it
    VerifyText     Hello! Please check these links            # Verifies part of the body text is present

    # 5. Open all URLs present in the email
    ClickText      ${URL_1}          # Opens the first link (opens in a new tab)
    SwitchWindow   1                 # Switches the bot's focus back to the first tab (Gmail)
    
    ClickText      ${URL_2}          # Opens the second link (opens in a new tab)
    SwitchWindow   1                 # Switches focus back to Gmail again