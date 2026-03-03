*** Settings ***
Library    QWeb

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA
    [Documentation]    Automates the login flow using secure Project Settings variables and waits for manual Push MFA.

    # 1. Navigate to the Copado login page
    OpenBrowser    https://robotic.copado.com/u/login    chrome
    VerifyText     Log in to Copado

    # 2. Select Google SSO
    ClickText      Continue with Google

    # 3. Google Sign-in Screen
    VerifyText     Sign in
    TypeText       Email or phone    ${C_EMAIL}
    ClickText      Next

    # 4. Okta Credentials Screen (Reusing the ${EMAIL} variable)
    VerifyText     Connecting to
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In

    # 5. Okta Verify (Push) Screen
    VerifyText     Okta Verify
    ClickText      Send Push

    # 6. Wait for manual MFA approval and verify we reached the Home Page
    VerifyText     Welcome back      timeout=60s
    VerifyText     Project Overview