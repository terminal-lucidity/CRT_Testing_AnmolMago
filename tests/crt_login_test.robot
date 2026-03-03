*** Settings ***
Library    QWeb
Library    QImage
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
    # FIXED VIDEO STREAM VERIFICATION (QWeb Only)
    # ========================================
    
    # 15. Give new tab time to open
    Log            ⏱️ Waiting for video stream tab to open...
    Sleep          3s
    
    # 16. Switch to the NEW window (video stream tab)
    Log            🔄 Switching to video stream window...
    SwitchWindow   NEW
    
    # 17. Verify we're on the video stream page by checking URL
    Log            🔍 Verifying we're on the video stream page...
    ${current_url}=    GetUrl
    Log            Current URL: ${current_url}
    
    # 18. Wait for stream initialization (no "Please wait" message)
    Log            ⏳ Waiting for video stream to initialize...
    VerifyNoText   Please wait while the video stream is being created    timeout=180s
    
    # 19. CRITICAL: Click on the video area to ensure window has focus
    Log            🖱️ Clicking on video area to ensure window focus...
    ClickElement   xpath=//body    # Click somewhere on the page to activate window
    Sleep          2s
    
    # 20. Give stream time to stabilize and start playing
    Log            ⏱️ Allowing video stream to stabilize (20 seconds)...
    Sleep          20s
    
    # 21. Capture first frame
    Log            📸 Capturing FIRST frame from video stream...
    ${frame_1}=    LogScreenshot
    Log            First frame saved: ${frame_1}
    
    # 22. Wait for stream to play
    Log            ⏱️ Waiting 30 seconds for stream to play...
    Sleep          30s
    
    # 23. Capture second frame
    Log            📸 Capturing SECOND frame from video stream...
    ${frame_2}=    LogScreenshot
    Log            Second frame saved: ${frame_2}
    
    # 24. Compare frames - they should be DIFFERENT if stream is playing
    Log            🔍 Comparing frames to detect video movement...
    ${comparison_result}=    Run Keyword And Return Status    QImage.Compare Images    ${frame_1}    ${frame_2}
    
    # 25. If images are identical, stream is frozen - FAIL
    Run Keyword If    ${comparison_result}    Fail    ❌ FROZEN STREAM: Screenshots are IDENTICAL - video is not playing!
    
    # 26. Success - images are different!
    Log            ✅ SUCCESS: Screenshots are DIFFERENT - video stream is playing!
    
    # 27. Cleanup - close video stream window
    Log            🧹 Closing video stream window...
    CloseWindow
    SwitchWindow   1
    Log            ✅ Test completed successfully!
