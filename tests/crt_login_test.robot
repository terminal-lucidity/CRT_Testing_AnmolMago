*** Settings ***
Library    QWeb
Library    QImage
Library    OperatingSystem
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA
    [Documentation]    Automates the login flow, opens video stream, and verifies stream is working

    # Steps 1-14: Login and navigation (keeping as-is)
    GoTo   https://robotic.copado.com/u/login
    VerifyText     Log in to Copado
    ClickText      Continue with Google
    VerifyText     Sign in
    TypeText       Email or phone    ${C_EMAIL}
    ClickText      Next
    VerifyText     Connecting to
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In
    VerifyText     Okta Verify
    ClickText      Send Push         sleep=60s
    VerifyText     Welcome back      timeout=60s
    VerifyText     Project Overview
    ClickElement   xpath=//app-switcher[@id='project-select']//button
    ClickText      CopadoAI_Testing_Project_Anmol
    ClickText      Test Runs
    ClickText      4304928
    ClickText      Configuration
    ClickText      Enabled    anchor=Video Streaming and Recording
    ClickText      Save
    ClickElement   xpath=//button[@id='offcanvas-close-btn']
    ClickText      Re-Run
    ClickText      All Test Cases
    ClickText      Open Video Stream
    ClickText      Run Now

    # ========================================
    # FIXED VIDEO STREAM VERIFICATION (QWeb Only)
    # ========================================
    
    Log            Waiting for video stream tab to open
    Sleep          10s
    Log            Switching to video stream window
    SwitchWindow    NEW
    
    ${has_error}=    ExecuteJavascript    return document.querySelector('video') ? (document.querySelector('video').error !== null) : false;
    
    Should Be True    not ${has_error}    msg=The video player entered an error state.
    ${is_paused}=    ExecuteJavascript    return document.querySelector('video') ? document.querySelector('video').paused : true;
    Should Be True    not ${is_paused}    msg=The video player is paused.