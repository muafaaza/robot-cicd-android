*** Variables ***
# Diverifikasi live via Appium/UiAutomator2 terhadap com.swaglabsmobileapp v2.7.1
${LOGIN_USERNAME_INPUT}      accessibility_id=test-Username
${LOGIN_PASSWORD_INPUT}      accessibility_id=test-Password
${LOGIN_SUBMIT_BUTTON}       accessibility_id=test-LOGIN
# Container accessibility-id-nya sendiri teksnya kosong - pesan error ada di child TextView
${LOGIN_ERROR}               xpath=//*[@content-desc="test-Error message"]/android.widget.TextView
# Muncul di halaman Products setelah login berhasil, dipakai sebagai penanda "sudah pindah halaman"
${PRODUCTS_SCREEN_MARKER}    accessibility_id=test-Cart
