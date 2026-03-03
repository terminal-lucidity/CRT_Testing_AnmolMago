*** Settings ***
Library    QWeb
Library    QImage
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing With Okta MFA
    [Documentation]    Automates the login flow using secure Project Settings variables and waits for manual Push MFA.

    # 1. Navigate to the Copado login page
    GoTo   https://robotic.copado.com/u/login
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
    ClickText      Send Push         sleep=60s

    # 6. Wait for manual MFA approval and verify we reached the Home Page
    VerifyText     Welcome back      timeout=60s
    VerifyText     Project Overview
    # 7. Open the Project Dropdown
    ClickElement   xpath=//app-switcher[@id='project-select']//button
    
    # 8. Select the target project
    ClickText      CopadoAI_Testing_Project_Anmol
    
    # 9. Navigate to Test Runs in the left sidebar
    ClickText      Test Runs

    # 10. Click on the Run ID
    # Note: We are using the exact ID from your screenshot for now.
    ClickText      4272472

    # 11. Click on Configuration
    ClickText      Configuration
    
    # 12. Disable Video Streaming and Recording
    # The anchor ensures we click the 'Disabled' button associated with Video Streaming
    ClickText      Enabled    anchor=Video Streaming and Recording
    ClickText      Save
    # 13. Close the Configuration off-canvas popup using its exact ID
    ClickElement   xpath=//button[@id='offcanvas-close-btn']
    
    # 14. Click Rerun to execute the test job again
    ClickText      Re-Run
    ClickText      All Test Cases
    ClickText      Open Video Stream
    ClickText      Run Now
# 15. Switch focus to the newly opened tab
    SwitchWindow    NEW
    
    # 16. WAIT for the Copado backend to finish building the stream
    VerifyNoText    Please wait while the video stream is being created    timeout=120s
    
    # 17. Give the canvas 5 seconds to stabilize and start rendering the feed
    Sleep           100s
    
    # 18. Take Snapshot #1: QWeb's LogScreenshot takes a picture and saves the file path to our variable
    ${frame_1}=     LogScreenshot
    
    # 19. Let the stream play for 3 seconds
    Sleep           3s
    
    # 20. Take Snapshot #2
    ${frame_2}=     LogScreenshot
    
    # 21. Prove the video is playing by visually comparing the screenshots!
    # If the video is frozen, CompareImages passes (which fails our test).
    # If the video is playing, CompareImages throws an error (which passes our test!).
    Run Keyword And Expect Error    * CompareImages    ${frame_1}    ${frame_2}
    
    # 22. Close the window and return to the main dashboard
    CloseWindow
    SwitchWindow    1