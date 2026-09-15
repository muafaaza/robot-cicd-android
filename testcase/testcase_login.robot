*** Settings ***
Documentation      Test Case Login Swag Labs Mobile App (Android) - kredensial valid, password salah, dan field kosong
Resource           ../keywords/keyword_login_app.robot
Resource           ../resource/testdata/testdata_login.robot
Suite Setup        Open Swag Labs App
Suite Teardown     Close App Session
Test Setup         Go To Login Screen

*** Test Cases ***
TC01 - Login Dengan Kredensial Valid
    [Documentation]    User berhasil login dan diarahkan ke halaman Products
    [Tags]    smoke    login    positive
    Login As User    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Products Screen Should Be Displayed

TC02 - Login Dengan Password Salah
    [Documentation]    Sistem menampilkan pesan error saat password salah
    [Tags]    regression    login    negative
    Login As User    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Login Error Should Be Displayed    ${LOGIN_ERROR_MESSAGE}

TC03 - Login Dengan Field Kosong
    [Documentation]    Sistem menampilkan validasi required saat username dan password kosong
    [Tags]    regression    login    negative
    Login As User    ${EMPTY}    ${EMPTY}
    Login Error Should Be Displayed    ${EMPTY_FIELD_ERROR_MESSAGE}
