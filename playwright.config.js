const path = require('node:path');

const appDir = path.resolve(__dirname);
const defaultAppUrl = 'http://127.0.0.1:8080';

module.exports = {
  testDir: './e2e',
  timeout: 90_000,
  use: {
    baseURL: process.env.PLAYWRIGHT_APP_URL || defaultAppUrl,
    locale: 'ko-KR',
    viewport: {
      width: 390,
      height: 844,
    },
    ignoreHTTPSErrors: true,
  },
  webServer: process.env.SKIP_PLAYWRIGHT_WEBSERVER
    ? undefined
    : {
        command: `cd ${appDir} && flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080`,
        url: defaultAppUrl,
        timeout: 180_000,
        reuseExistingServer: true,
        stderr: 'pipe',
        stdout: 'pipe',
      },
  reporter: [['list']],
};
