*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py
Resource          aps_keywords.robot

*** Keywords ***
Get Field Amount
    [Arguments]    ${id}
    ${path}=    Set Variable    ${id}
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}

Get Field Text
    [Arguments]    ${id}
    Wait Until Element Is Visible    ${id}
    ${r}=    Get Text    ${id}
    [Return]    ${r}

Prepare View
    [Arguments]    ${username}    ${argument}
    ${is_tender_open}=    Set Variable    000
    ${is_tender_open}=    Run Keyword And Ignore Error    Page Should Contain    ${argument}
    Run Keyword If    '${is_tender_open[0]}'=='FAIL'    Go To    ${USERS.users['${username}'].homepage}
    Run Keyword If    '${is_tender_open[0]}'=='FAIL'    Search tender    ${username}    ${argument}
    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']

Get Field feature.title
    [Arguments]    ${id}
    Wait Until Element Is Enabled    id=features-tab
    Click Element    id=features-tab
    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Execute Javascript    window.scroll(0, 150)
    ${d}=    Set Variable    ${id}
    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Wait Until Element Is Enabled    id = updateOrCreateFeature_0_0    30
    Get Field Text    xpath=//form[contains(@id,'updateOrCreateFeature_${id}')]

Get Field Date
    [Arguments]    ${id}
    ${startDate}=    Get Text    ${id}
    ${startDate}    Replace String    ${startDate}    ${SPACE}    T
    ${tz}=    Get Local TZ
    ${startDate}=    Set Variable    ${startDate}.000000+0${tz}:00
    Return From Keyword    ${startDate}

Set Field tenderPeriod.endDate
    [Arguments]    ${value}
    ${date_time_ten_end}=    Replace String    ${value}    T    ${SPACE}
    ${date_time_ten_end}=    Fetch From Left    ${date_time_ten_end}    +0
    Wait Until Element Is Enabled    ${locator_bidDate_end}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Full Click    id=createOrUpdatePurchase

Set Field
    [Arguments]    ${_id}    ${value}
    Wait Until Element Is Enabled    ${_id}
    ${eee}=    Convert Float To String    ${value}
    Input Text    ${_id}    ${eee}
    Click Element    ${_id}

Conv to Boolean
    [Arguments]    ${id}
    ${path}=    Set Variable    ${id}
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert To Boolean    ${r}
    Return From Keyword    ${r}

Set Field Text
    [Arguments]    ${idishka}    ${text}
    Wait Until Page Contains Element    ${idishka}
    Wait Until Element Is Visible    ${idishka}
    Wait Until Element Is Enabled    ${idishka}
    Input Text    ${idishka}    ${text}

Get Field Question
    [Arguments]    ${x}    ${field}
    Full Click    id=questions-tab
    Wait Until Page Contains    ${x}    60
    ${txt}=    Get Text    ${field}
    Return From Keyword    ${txt}

Get Tender Status
    Reload Page
    ${status}=    Execute Javascript    return $('#purchaseStatus').text()
    Run Keyword If    '${status}'=='1'    Return From Keyword    draft
    Run Keyword If    '${status}'=='2'    Return From Keyword    active.enquiries
    Run Keyword If    '${status}'=='3'    Return From Keyword    active.tendering
    Run Keyword If    '${status}'=='4'    Return From Keyword    active.auction
