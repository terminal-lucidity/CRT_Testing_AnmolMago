*** Settings ***
Library    QWeb
Library                 QWeb
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
# 15. Switch focus to the newly opened tab
    SwitchWindow    NEW
    
    # 16. WAIT for the loading screen to disappear
    VerifyNoText    Please wait while the video stream is being created    timeout=120s
    
    # 17. Verify the video player has loaded by looking for its starting timestamp
    # This proves the player UI successfully initialized and the stream is ready
    VerifyText      0:00    timeout=15s
    
    # 18. (Optional) Give it a few seconds to play, then verify the time has moved past 0:00
    # Note: This step depends on how fast the text updates in the DOM. If it fails, remove steps 18 & 19!
    Sleep           5s
    VerifyNoText    0:00    timeout=10s
    
    # 19. Close the window and return to the main dashboard
    CloseWindow
    SwitchWindow    1

