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
Get Field value.amount
    ${r}=    Get Text    xpath=.//*[@id='purchaseBudget']
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Remove String    ${r}    UAH
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}
    [Return]    ${value}

Get Field tenderPeriod.startDate
    ${startDate}=    Get Text    id=purchasePeriodTenderStart
    ${startDate}    Replace String    ${startDate}    ${SPACE}    T
    Return From Keyword    ${startDate}
    [Return]    ${startDate}

Get Field tenderPeriod.endDate
    ${endDate}=    Get Text    id=purchasePeriodTenderEnd
    ${endDate}=    Replace String    ${endDate}    ${SPACE}    T
    Return From Keyword    ${endDate}
    [Return]    ${endDate}

Get Field item.description
    [Arguments]    ${id}
    ${path}=    Set Variable    xpath=//h4[@class='m-t-xxs m-b-sm procurementSubjectNameUa ng-binding'][contains(.,'${id}')]
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    Return From Keyword    ${r}

Get Field lot.description
    [Arguments]    ${id}
    ${path}=    Set Variable    xpath=//h4[@id='Lot-1-Title'][contains(.,'${id}')]
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    Return From Keyword    ${r}

Get Field lot.value.amount
    [Arguments]    ${id}
    ${path}=    Set Variable    id=Lot-1-Budget
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}

Get Field lot.minimalStep.amount
    ${path}=    Set Variable    id=Lot-1-MinStep
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}

Get Field Amount
    [Arguments]    ${id}
    ${path}=    Set Variable    ${id}
    Wait Until Element Is Visible    ${path}
    ${r}=    Get Text    ${path}
    ${r}=    Remove String    ${r}    ${SPACE}
    ${r}=    Convert To Number    ${r}
    Return From Keyword    ${r}
