*** Settings ***
Library           Selenium2Library

*** Keywords ***
Find model
    [Arguments]    ${id}
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('${id}')).scope();

Define angular
    [Arguments]    ${model}    ${id}    ${descr}
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('${id}')).scope(); autotestmodel.${model}.${id}="${descr}";

Define angular date start
    [Arguments]    ${model}    ${id}    ${descr}    ${name}
    Execute Javascript    var ttt=angular.element(document.getElementById('${id}')).scope(); ttt.${model}.${name}={}; ttt.${model}.${name}.start="${descr}";

Define angular date end
    [Arguments]    ${model}    ${id}    ${descr}    ${name}
    Execute Javascript    var ttt=angular.element(document.getElementById('${id}')).scope(); ttt.${model}.${name}={}; ttt.${model}.${name}.end="${descr}";

Define angular date
    [Arguments]    ${model}    ${id}    ${dt_start}    ${dt_end}    ${name}
    Execute Javascript    var ttt=angular.element(document.getElementById('${id}')).scope(); ttt.${model}.${name}={}; ttt.${model}.${name}.end="${dt_end}";ttt.${model}.${name}.start="${dt_start}";

Define angular +id_mod
    [Arguments]    ${model}    ${id}    ${descr}    ${id_mod}
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('${id}')).scope(); autotestmodel.${model}.${id_mod}="${descr}";

Define angular +name+id_mod
    [Arguments]    ${model}    ${id}    ${descr}    ${id_mod}    ${name}
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('${id}')).scope(); autotestmodel.${model}.${name}.${id_mod}="${descr}";

Define angular date end -.End
    [Arguments]    ${model}    ${id}    ${descr}    ${name}
    Execute Javascript    var ttt=angular.element(document.getElementById('${id}')).scope(); ttt.${model}.${name}="${descr}";

Define angular with value
    [Arguments]    ${model}    ${id}    ${descr}    ${name}
    Execute Javascript    var ttt=angular.element(document.getElementById('${id}')).scope(); ttt.${model}.${name}="${descr}";
