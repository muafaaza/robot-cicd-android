# robot-android-cicd

Dummy project buat latihan CI/CD, versi mobile dari [`robot-cicd`](../robot-cicd) (yang web). Scope-nya sengaja dipersempit sama persis: cuma automation **Login** — kali ini app Android [Swag Labs Mobile](https://github.com/saucelabs/my-demo-app-android) (`com.swaglabsmobileapp`) via Appium, bukan browser via Selenium.

Kredensial demo: `standard_user` / `secret_sauce`

## Struktur

```
robot-android-cicd/
├── keywords/
│   └── keyword_login_app.robot       # keyword layer (buka app, input, verifikasi)
├── resource/
│   ├── locator/
│   │   └── locator_login.robot       # locator elemen halaman login (accessibility id)
│   └── testdata/
│       └── testdata_login.robot      # app package/activity + kredensial valid/invalid
├── testcase/
│   └── testcase_login.robot          # 3 test case: valid, password salah, field kosong
├── apk/                               # taruh APK-mu sendiri di sini (lihat bagian "APK" di bawah)
├── report/                            # output hasil run (di-gitignore, kecuali .gitkeep)
├── .github/workflows/robot-tests.yml  # CI pipeline (GitHub Actions)
└── requirements.txt
```

Layer architecture-nya sama persis kaya `robot-cicd`: `testcase → keyword → locator/testdata`.

## Beda dari `robot-cicd` (web)

| | robot-cicd (web) | robot-android-cicd (mobile) |
|---|---|---|
| Library | `SeleniumLibrary` | `AppiumLibrary` |
| Driver | Chrome (headless), auto via Selenium Manager | Appium server + UiAutomator2, butuh emulator/device |
| Per-test isolation | `Open Browser` baru tiap test, `Close Browser` di teardown | Session Appium dibuka **sekali** (`Suite Setup`), tiap test cuma **relaunch app** (`Test Setup`) — lihat catatan di bawah |
| CI runner | `ubuntu-latest` | `macos-latest` (butuh hardware acceleration buat Android emulator) |
| Artifact aplikasi | Tidak perlu (website live) | Butuh APK, kamu sediakan sendiri (lihat bagian "APK") |

**Kenapa bukan "buka/tutup session penuh tiap test" kaya versi web?**
Awalnya saya coba persis kaya `robot-cicd` (Appium session baru tiap test case). Ternyata di Android:
- Session baru dengan `noReset=true` → app-nya **tidak** balik ke Login screen (nyangkut di state terakhir, misal masih di halaman Products dari test sebelumnya) → test berikutnya gagal cari elemen login.
- Session baru pakai reset default (clear app data) → kadang malah nyangkut di home screen launcher, gak jadi buka app-nya sama sekali.

Fix yang stabil (sudah diverifikasi 2x run beruntun, 3/3 PASS tiap kali): buka **satu** Appium session di `Suite Setup`, terus tiap test relaunch app pakai `Terminate Application` + `Activate Application` di `Test Setup` — ini konsisten balik ke Login screen bersih tanpa app data ke-reset atau nyangkut di launcher.

## APK

Nggak ada APK yang di-bundle di repo ini. Kenapa:
- App yang dipakai (`com.swaglabsmobileapp`) di-develop dari [saucelabs/my-demo-app-android](https://github.com/saucelabs/my-demo-app-android), tapi versi yang kepake sebelumnya (`2.7.1`) **tidak ada** di release resmi mereka (release resmi cuma sampai `2.2.0`) — jadi saya nggak mau nebak/download APK dari sumber yang nggak jelas asalnya.
- Taruh APK kamu sendiri di `apk/` (nama file bebas, workflow otomatis pakai file `.apk` pertama yang ketemu di folder itu) sebelum push, atau install manual dulu ke emulator kalau cuma mau run lokal.
- `.gitignore` nge-exclude `*.apk` secara default (biar gak accidentally commit binary gede) — kalau kamu mau APK-nya ikut ke-commit (perlu buat CI di GitHub Actions), pakai `git add -f apk/nama-app-kamu.apk`.

## Jalanin Lokal

```bash
cd robot-android-cicd
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 1. Pastikan emulator/device Android nyala dan `adb devices` mendeteksinya
adb devices

# 2. Install app-nya kalau belum ada di device (skip kalau sudah ter-install)
adb install apk/nama-app-kamu.apk

# 3. Jalanin Appium server di terminal terpisah (default port 4723, base path "/" -
#    JANGAN pakai /wd/hub, Appium 2.x/3.x udah gak butuh itu)
appium

# 4. Run test-nya
robot --outputdir report testcase/
```

Kalau Appium server-mu jalan di port lain, override lewat CLI:
```bash
robot --variable APPIUM_URL:http://127.0.0.1:4724 --outputdir report testcase/
```

Hasil run: buka `report/log.html` atau `report/report.html`.

## Belajar CI/CD-nya

Workflow-nya udah disiapin di `.github/workflows/robot-tests.yml` — jalan otomatis tiap `push`/`pull_request` ke branch `main`: setup Python + Node, install Appium + driver UiAutomator2, start Appium server, spin up Android emulator (API 30, Pixel 5, x86_64) via `reactivecircus/android-emulator-runner`, install APK dari folder `apk/`, run 3 test case di atas, upload `report/` sebagai artifact.

Langkah yang perlu kamu lakuin sendiri (ini bagian latihannya, sama kaya `robot-cicd`):

1. Taruh APK-mu di `apk/` (lihat bagian "APK" di atas), lalu `git add -f apk/nama-app-kamu.apk`.
2. `git init` di folder `robot-android-cicd/` ini (biar terpisah dari project qa-agentic lain).
3. Bikin repo baru di GitHub, misal `robot-android-cicd`.
4. `git add . && git commit -m "init: robot framework android login automation"` lalu push ke repo tsb.
5. Buka tab **Actions** di GitHub repo-nya — pipeline bakal auto-trigger dari push pertama. Siap-siap, boot emulator Android itu step paling lama di CI (bisa beberapa menit).
6. Coba ubah test data jadi sengaja gagal (misal ganti `LOGIN_ERROR_MESSAGE`), push lagi, lihat gimana Actions nampilin status merah + report artifact-nya bisa didownload.

Dari situ tinggal eksperimen: ganti API level/device profile emulator, tambah step screenshot-on-failure, notifikasi Slack on failure, dsb.
