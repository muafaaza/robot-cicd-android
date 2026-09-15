*** Settings ***
Documentation    Keyword layer untuk automation Login Swag Labs Mobile App (Android).
...              Session Appium dibuka sekali (Suite Setup), tiap test relaunch app
...              (Terminate + Activate) buat balik ke Login screen yang bersih - lebih
...              stabil dibanding buka/tutup session Appium penuh tiap test (verified
...              live: full reset via Open Application kadang bikin app nyangkut di
...              home screen, sedangkan Terminate+Activate konsisten balik ke Login).
Library          AppiumLibrary
Resource         ../resource/locator/locator_login.robot
Resource         ../resource/testdata/testdata_login.robot

*** Keywords ***
Open Swag Labs App
    [Documentation]    Buka Appium session dan launch app Swag Labs Mobile di device/emulator.
    ...                Dipanggil sekali di Suite Setup.
    [Arguments]    ${appium_url}=${APPIUM_URL}    ${device}=${DEVICE_NAME}
    Open Application    ${appium_url}
    ...    platformName=Android
    ...    deviceName=${device}
    ...    automationName=UiAutomator2
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    noReset=${TRUE}
    ...    newCommandTimeout=300
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=15s

Go To Login Screen
    [Documentation]    Relaunch app fresh supaya tiap test mulai dari Login screen bersih,
    ...                setara "Open Browser baru" di suite web. Dipanggil di Test Setup.
    Terminate Application    ${APP_PACKAGE}
    Activate Application    ${APP_PACKAGE}
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=15s

Input Login Credentials
    [Documentation]    Isi username dan password pada form login
    [Arguments]    ${username}    ${password}
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Input Text    ${LOGIN_PASSWORD_INPUT}    ${password}

Click Login Button
    Click Element    ${LOGIN_SUBMIT_BUTTON}

Login As User
    [Documentation]    Isi kredensial dan submit (asumsi sudah di Login screen)
    [Arguments]    ${username}    ${password}
    Input Login Credentials    ${username}    ${password}
    Click Login Button

Products Screen Should Be Displayed
    [Documentation]    Verifikasi user berhasil masuk ke halaman Products
    Wait Until Page Contains Element    ${PRODUCTS_SCREEN_MARKER}    timeout=15s

Login Error Should Be Displayed
    [Documentation]    Verifikasi pesan error muncul (credential invalid atau field kosong)
    [Arguments]    ${expected_message}
    Wait Until Page Contains Element    ${LOGIN_ERROR}    timeout=10s
    ${actual}=    Get Text    ${LOGIN_ERROR}
    Should Be Equal As Strings    ${actual}    ${expected_message}

Close App Session
    [Documentation]    Tutup Appium session. Dipanggil sekali di Suite Teardown.
    Close Application
