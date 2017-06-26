*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py

*** Keywords ***
Get Field item.description
    [Arguments]    ${id}
    ${path}=    Set Variable    xpath=//h4[@class='m-t-xxs m-b-sm procurementSubjectNameUa ng-binding'][contains(.,'${id}')]
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    Return From Keyword    ${r}

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
    Execute Javascript    window.scroll(0, 2000)
    ${d}=    Set Variable    ${id}
    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Wait Until Element Is Enabled    id = updateOrCreateFeature_0_0    30
    Get Field Text    xpath=//form[contains(@id,'updateOrCreateFeature_${id}')]/

Get Field Date
    [Arguments]    ${id}
    ${startDate}=    Get Text    ${id}
    ${startDate}    Replace String    ${startDate}    ${SPACE}    T
    Return From Keyword    ${startDate}
