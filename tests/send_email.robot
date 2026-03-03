*** Settings ***
Library                 QWeb
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA And Open Gmail
    [Documentation]    Automates the login flow using secure Project Settings variables, waits for manual Push MFA, opens Gmail, and hits compose.

    # 1. Navigate to the Google login page
    GoTo           https://mail.google.com
    VerifyText     Sign in
    TypeText       Email or phone    ${C_EMAIL}
    ClickText      Next

    # 2. Okta Credentials Screen (Reusing the ${C_EMAIL} variable)
    VerifyText     Connecting to
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In

    # 3. Okta Verify (Push) Screen
    VerifyText     Okta Verify
    # Note: Using 'timeout' instead of 'sleep' inside QWeb keywords to wait for the push approval
    ClickText      Send Push         timeout=60s   

    VerifyText     Inbox             timeout=15s    

    
    # 5. Hit Compose
    ClickText      Compose
    VerifyText     New Message