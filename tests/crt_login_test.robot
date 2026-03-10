*** Settings ***
Library    QWeb
Library    QImage
Library    OperatingSystem
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Variables ***
${LOGIN_URL}            https://robotic.copado.com/u/login
${PROJECT_NAME}         CopadoAI_Testing_Project_Anmol

*** Test Cases ***
UC002: Login To Copado Robotic Testing + E2E Test Flow
    [Documentation]    Automates login, selects project, opens latest test run, toggles stream, and verifies video

    # LOGIN
    GoTo           ${LOGIN_URL}
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

    # PROJECT & TEST RUN NAVIGATION

    ClickElement   xpath=//app-switcher[@id='project-select']//button
    ClickText      ${PROJECT_NAME}
    
    ClickText      Test Runs

    VerifyElement    xpath=(//div[@col-id="buildNumber"]//a)[1]    timeout=10s
    ClickElement     xpath=(//div[@col-id="buildNumber"]//a)[1]
    # CONFIGURATION & TOGGLE
    ClickText      Configuration
    
    ClickText      Disabled    anchor=Video Streaming and Recording
    Run Keyword And Ignore Error    ClickText    Save

    ClickText      Enabled     anchor=Video Streaming and Recording
    ClickText      Save
    
    ClickElement   xpath=//button[@id='offcanvas-close-btn']
    # TEST EXECUTION
    ClickText      Re-Run
    ClickText      All Test Cases
    ClickText      Open Video Stream
    ClickText      Run Now

    # VIDEO STREAM VERIFICATION 
    Log            Waiting for new video stream window
    SwitchWindow    NEW
    Sleep           20s
    SwitchWindow    NEW
    Log             Capturing the first frame
    Log Screenshot  frame_1.png
    
    Log             Waiting 30 seconds to capture playback progress
    Sleep           30s
    
    SwitchWindow    NEW
    Log             Capturing the second frame
    Log Screenshot  frame_2.png
    
    Log             Comparing the two frames...
    ${images_match}=    Run Keyword And Return Status    Compare Images    frame_1.png    frame_2.png    tolerance=0.80
    
    Should Be True    not ${images_match}    msg=Video stream appears frozen! Both frames matched.