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
    ${r}=    Replace String    ${r}    ,    .
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}

Get Field Text
    [Arguments]    ${id}
    Wait Until Element Is Enabled    ${id}    60
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
    Comment    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    sleep    3000
    Wait Until Page Contains Element    id=Feature_1_0_Title    30
    Execute Javascript    window.scroll(0, 150)
    ${d}=    Set Variable    ${id}
    Comment    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Comment    Wait Until Element Is Enabled    id = updateOrCreateFeature_0_0    30
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

Set Field Amount
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
    sleep    5
    Full Click    id=questions-tab
    Wait Until Page Contains    ${x}    60
    ${txt}=    Get Text    ${field}
    Return From Keyword    ${txt}

Get Tru PDV
    [Arguments]    ${rrr}
    ${txt}=    Get Element Attribute    purchaseIsVAT@isvat
    Return From Keyword If    '${txt}'=='true'    ${True}
    Return From Keyword If    '${txt}'!='true'    ${False}

Get Tender Status
    Reload Page
    ${status}=    Execute Javascript    return $('#purchaseStatus').text()
    Run Keyword If    '${status}'=='1'    Return From Keyword    draft
    Run Keyword If    '${status}'=='2'    Return From Keyword    active.enquiries
    Run Keyword If    '${status}'=='3'    Return From Keyword    active.tendering
    Run Keyword If    '${status}'=='4'    Return From Keyword    active.auction

Get Contract Status
    Reload Page
    ${contr_status}=    Execute Javascript    return $('#contractStatusName_').text()
    Run Keyword If    '${status}'=='1'    Return From Keyword    pending
    Run Keyword If    '${status}'=='2'    Return From Keyword    active

Get Field question.answer
    [Arguments]    ${www}
    Full Click    id=questions-tab
    Wait Until Page Contains    ${x}    60
    ${txt}=    Get Text    xpath=//div[contains(text(),'${x}')]
    Return From Keyword    ${txt}

Get Field Amount for latitude
    [Arguments]    ${id}
    ${path}=    Set Variable    ${id}
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert Float To String    ${r}
    Return From Keyword    ${r}

Get Field Doc
    [Arguments]    ${idd}
    Full Click    documents-tab
    ${rrr}=    Get Text    ${idd}
    Return From Keyword    ${rrr}

Get Field Doc for paticipant
    [Arguments]    ${idd}
    Full Click    participants-tab
    ${rrr}=    Get Text    ${idd}
    Return From Keyword    ${rrr}

Get Claim Status
    [Arguments]    ${yyy}
    ${text}=    Get Text    ${yyy}
    Return From Keyword If    '${text}'=='Вимога'    claim
    Return From Keyword If    '${text}'=='Дано відповідь'    answered
    Return From Keyword If    '${text}'=='Вирішено'    resolved
    Return From Keyword If    '${text}'=='Скасований'    cancelled
    Return From Keyword If    '${text}'=='Чернетка'    draft
    Return From Keyword If    '${text}'=='Відхилено'    declined
    Return From Keyword If    '${text}'=='Недійсно'    invalid

Get Answer Status
    [Arguments]    ${_id}
    ${txt}=
    Return From Keyword If    '${txt}'=='Недійсно'    declined
    Return From Keyword If    '${txt}'=='Відхилено'    cancelled
    Return From Keyword If    '${txt}'=='Вирішено'    resolved

Set Click For Award
    [Arguments]    ${idd}

Get NAward Field
    [Arguments]    ${fu}    ${is_amount}
    Full Click    participants-tab
    Return From Keyword if    ${is_amount}==${True}    Get Field Text    ${fu}
    Return From Keyword if    ${is_amount}==${False}    Get Field Amount    ${fu}

Get Satisfied
    [Arguments]    ${g}
    ${msg}=    Set Variable    0
    ${msg}=    Run Keyword And Ignore Error    Element Should Be Visible    complaintSatifiedTrue_${g}
    Return From Keyword If    '${msg[0]}'=='PASS'    ${True}
    ${msg}=    Run Keyword And Ignore Error    Element Should Be Visible    complaintSatifiedFalse_${g}
    Return From Keyword If    '${msg[0]}'=='PASS'    ${False}

Open Claim Form
    [Arguments]    ${uaid}
    Full Click    claim-tab
    Wait Until Page Contains Element    //span[contains(.,'${uaid}')]
    sleep    3
    ${guid}=    Get Text    //span[text()='${uaid}']/..//span[contains(@id,'complaintGuid')]
    Full Click    openComplaintForm_${guid}
    Wait Until Element Is Enabled    complaintStatus_${guid}
    [Return]    ${guid}
