*** Settings ***
Library                 QWeb
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA And Send Email
    [Documentation]    Automates the login flow, waits for manual Push MFA, opens Gmail, hits compose, and sends an email.

    # 1. Navigate to Gmail login
    GoTo           https://mail.google.com
    VerifyText     Sign in
    TypeText       Email or phone    ${C_EMAIL}
    ClickText      Next

    # 2. Okta Credentials Screen
    VerifyText     Connecting to
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In

    # 3. Okta Verify (Push) Screen
    VerifyText     Okta Verify
    ClickText      Send Push         timeout=60s   
    VerifyText     Inbox             timeout=15s    
    
    # 4. Hit Compose
    ClickText      Compose
    VerifyText     New Message       timeout=10s

    # 5. Fill out the email and send
    TypeText       To                ${A_EMAIL}
    PressKey       To                {ENTER}
    TypeText       Subject           Automated Test Email
    TypeText       Message Body      Hello, this is an automated email sent via Copado Robotic Testing!
    
    ClickText      Send
    
    # 6. Verify success
    VerifyText     Message sent      timeout=15s