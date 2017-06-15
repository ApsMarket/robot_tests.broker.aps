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
    ${r}=    Replace String    ${r}    ' '    ${EMPTY}
    ${r}=    Replace String    ${r}    UAH    ${EMPTY}
    Return From Keyword    ${r}
    [Return]    ${value}
