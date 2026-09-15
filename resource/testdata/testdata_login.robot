*** Variables ***
${APPIUM_URL}             http://127.0.0.1:4723
${DEVICE_NAME}            emulator-5554
${APP_PACKAGE}            com.swaglabsmobileapp
${APP_ACTIVITY}           com.swaglabsmobileapp.MainActivity

${VALID_USERNAME}         standard_user
${VALID_PASSWORD}         secret_sauce

${INVALID_USERNAME}       standard_user
${INVALID_PASSWORD}       wrong_password

${LOGIN_ERROR_MESSAGE}          Username and password do not match any user in this service.
${EMPTY_FIELD_ERROR_MESSAGE}     Username is required
