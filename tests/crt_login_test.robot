*** Settings ***
Library    QWeb
Library    QImage
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA
    [Documentation]    Automates the login flow, opens video stream, and verifies stream is working

    # 1-14: Login steps (keeping as-is)
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
    ClickText      4272472
    ClickText      Configuration
    ClickText      Enabled    anchor=Video Streaming and Recording
    ClickText      Save
    ClickElement   xpath=//button[@id='offcanvas-close-btn']
    ClickText      Re-Run
    ClickText      All Test Cases
    ClickText      Open Video Stream
    ClickText      Run Now

    # ========================================
    # FIXED VIDEO STREAM VERIFICATION
    # ========================================
    
    # 15. Switch to video stream window
    SwitchWindow    NEW
    
    # 16. Wait for stream to initialize (not "Please wait")
    Log    Waiting for video stream to initialize...
    VerifyNoText    Please wait while the video stream is being created    timeout=180s
    
    # 17. Give stream extra time to fully load and start rendering
    Log    Allowing video stream to stabilize and start playing...
    Sleep           20s
    
    # 18. Capture first frame
    Log    Capturing first frame...
    ${frame_1}=     LogScreenshot
    
    # 19. Let stream play
    Log    Waiting 5 seconds for stream to play...
    Sleep           5s
    
    # 20. Capture second frame
    Log    Capturing second frame...
    ${frame_2}=     LogScreenshot
    
    # 21. Compare frames - they should be DIFFERENT if stream is playing
    Log    Comparing frames to verify stream is playing...
    ${comparison_result}=    Run Keyword And Return Status    QImage.Compare Images    ${frame_1}    ${frame_2}
    
    # 22. If images are identical (comparison passed), stream is frozen - FAIL
    Run Keyword If    ${comparison_result}    Fail    ❌ Video stream is FROZEN - both screenshots are identical!
    
    # 23. If we reach here, images are different - stream is working!
    Log    ✅ SUCCESS: Video stream verified - frames are different, stream is playing!
    
    # 24. Close stream window and return to main window
    CloseWindow
    SwitchWindow    1
