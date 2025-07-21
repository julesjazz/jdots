const puppeteer = require('puppeteer-core');
const fs = require('fs');

const START_URL = 'https://d-92671f41c2.awsapps.com/start#';
const SSO_REGION = 'us-west-2';
const SSO_SESSION = 'cli-access';
const DEFAULT_REGION = 'us-west-2';

function normalizeAccountName(name) {
  return name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

(async () => {
  const browser = await puppeteer.launch({
    headless: false,
    executablePath: process.env.CHROMIUM_PATH,
    defaultViewport: null,
  });

  const page = await browser.newPage();
  await page.goto(START_URL);

  // Wait for the SSO app to fully load
  await page.waitForSelector('button[data-testid="account-list-cell"]', { timeout: 120000 });

  const accounts = await page.$$eval('button[data-testid="account-list-cell"]', (nodes) => {
    return nodes.map((node) => {
      const name = node.querySelector('strong')?.textContent ?? 'unknown';
      const idText = node.querySelector('div > div:nth-child(2)')?.textContent ?? '';
      const accountId = idText.trim().split(' ')[0];
      return { name, accountId };
    });
  });

  const accessLevels = ['administrator_access', 'oncall', 'monitoring'];

  let profileBody = `[sso-session ${SSO_SESSION}]
sso_start_url=${START_URL}
sso_region=${SSO_REGION}
sso_registration_scopes=sso:account:access

`;

  for (const { name, accountId } of accounts) {
    const slug = normalizeAccountName(name);
    const region = slug.includes('canada') || slug.includes('prod-ca') ? 'ca-central-1' : DEFAULT_REGION;

    for (const role of accessLevels) {
      profileBody += `[profile ${slug}-${accountId}-${role.replace(/_/g, '-')}]
sso_account_id=${accountId}
region=${region}
sso_session=${SSO_SESSION}
sso_region=${SSO_REGION}
sso_role_name=${role}
sso_start_url=${START_URL}

`;
    }
  }

  const outputPath = './aws-config.generated';
  fs.writeFileSync(outputPath, profileBody);
  console.log(`✅ AWS config written to ${outputPath}`);

  await browser.close();
})();