*** Settings ***
Documentation           New test suite
Library    QWeb
Library    QImage
Library    OperatingSystem
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Variables ***
${FABRIC_TEXTAREA}        xpath=//textarea[@data-fabric='textarea']

*** Test Cases ***
UC003: Verify E2E Flow
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
    ClickText      New Exploration
    
    TypeText    Title  Exploration1
    ClickText   Additional Settings
    TypeText    Starting URL   https://qentinelqi.github.io/shop/
    ClickText   Start Exploring
    Sleep       20s
    ClickElement    xpath=//*[@id='addFinding']
    ClickElement    xpath=//button[.//cds-icon[@shape='OfficeAndEditingTextAa']]
    ClickElement    xpath=//canvas[@data-fabric='top']    x=200    y=150
    
    TypeText    locator=xpath=//textarea[@data-fabric="textarea"]    input_text=Hello Copado!    visibility=False
    ClickText     Save
    ClickText     End Exploration
    ClickText     Yes, End
    ClickElement    xpath=//cds-icon[@shape='SystemAndDevicesDotsThreeRegularVertical']
    ClickText       Export
    ClickText       PDF (.pdf)
    ClickText       Export
    
    ClickElement    xpath=//cds-icon[@shape='SystemAndDevicesDotsThreeRegularVertical']