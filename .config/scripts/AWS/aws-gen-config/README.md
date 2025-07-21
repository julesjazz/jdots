Automatically gennerate AWS accounts instead of using an awkward bookmarklet!
> **RUN AT YOUR OWN RISK AND ALWAYS CREATE BACKUPS OF COURSE!**

1. make sure requirements are met and check caveats
2. copy your current `~/.aws/config` to `~/.aws/config.personal` (`mv ~/.aws/config ~/.aws/config.personal`)
3. make `aws-gen-config.sh` executable (`chmod +x {?}/aws-gen-config.sh`)


# Requirements
- python3 lts+ available globally
- puppeteer installed globally `npm install -g puppeteer-core`
- Chromium installed and available in shell PATH
- assumes awscli config is at `~/.aws`
- assumes that SSO auth is set up for AWS using Okta Verify (advised, haven't tested other auth methods)

## Caveats
- this is tested on Mac and Linux, Windows may require modifications
- mac chromium install via brew is buggy, install fresh with `brew install chromium --no-quarantine`
- `puppeteer` installs chromium along with `puppeteer-core`
    - splitting the install like this with global installs is more reliable in a simple script and avoids redownloading Chromium if you're just installing into this project dir
    - `puppeteer` full can be installed in the project dir, check the script for needed updates if desired
- Unsure how WSL will treat this as chromium gui is needed for auth. You may need to comment out the merge logic in the script and just send the output to a temp file for manual pasting...that is about the same as using the bookmarklet directly. `¯\_(°╭╮°)_/¯`

# What does this do?
1. this will use chromium for SSO initial login
2. once successful it may start a second authed session for chromium within puppet
3. the second auth session runs the bookmarket below to list aws accounts formatted
    - *puppeteer runs chromium*
4. the output of this is sent to `~/.aws/config.generated`
5. the generated config is then merged with your personal config, hopefully avoiding dupes with the result going to `./.aws/config`

# Confirming
This is intended to be an occasionally run script. You will still want to log in normally.
```sh
aws sso login --sso-session cli-access # this will open your typical preferred browser
# check available profiles after logging in
aws configure list-profiles
```

# File Structure
```sh
~/.aws
    config              # this will be the merged and updated config
    config.personal     # this is your baseline config and will not be touched
    config.generated    # this is the config pulled from the bookmarklet
    credentials         # DO NOT TOUCH OR SHARE THIS
    # other aws cli stuff...
```
# Starter config
Sometimes without a default config this can encounter errors. I would suggest just adding a basic config to `~/.aws/config` (or `config.personal` if it is otherwise empty) after backing up if issues are encountered.
```
[default]
region = us-west-2
output = json


[profile personal]
region = us-east-2
output = json


[profile localstack]
region = us-west-2
output = json


[profile local]
region = us-west-2
output = json
```

# Bookmarket
```js
javascript:(function()%7Baccounts%20%3D%20document.querySelectorAll('button%5Bdata-testid%3D%22account-list-cell%22%5D')%0AaccessLevels%20%3D%20%5B'administrator_access'%2C%20'oncall'%2C%20'monitoring'%5D%0A%0AprofileBody%20%3D%20%60%5Bsso-session%20cli-access%5D%0Asso_start_url%3Dhttps%3A%2F%2Fd-92671f41c2.awsapps.com%2Fstart%23%0Asso_region%3Dus-west-2%0Asso_registration_scopes%3Dsso%3Aaccount%3Aaccess%0A%0A%5Bprofile%20ecr-pull%5D%0Asso_account_id%3D358974996326%0Aregion%3Dus-west-2%0Asso_session%3Dcli-access%0Asso_region%3Dus-west-2%0Asso_role_name%3Dmonitoring%0Asso_start_url%3Dhttps%3A%2F%2Fd-92671f41c2.awsapps.com%2Fstart%23%0A%0A%60%0Aaccounts.forEach(account%20%3D%3E%20%7B%0A%20%20%20%20console.log(account)%0A%20%20%20%20let%20accountName%20%3D%20account.querySelector('strong').textContent%20%2F%2F%20need%20to%20normalize%20this%0A%20%20%20%20accountName%20%3D%20accountName.toLowerCase().replace(%2F%5Cs%2B%2Fg%2C%20'-').replace(%2F%5B%5Ea-z0-9-%5D%2Fg%2C%20'')%0A%20%20%20%20let%20region%20%3D%20%22us-west-2%22%0A%20%20%20%20if%20(accountName.includes(%22canada%22)%20%7C%7C%20accountName.includes(%22prod-ca%22))%20%7B%0A%20%20%20%20%20%20%20%20region%20%3D%20%22ca-central-1%22%0A%20%20%20%20%7D%0A%20%20%20%20window.accountName%20%3D%20accountName%0A%20%20%20%20window.account%20%3D%20account%0A%20%20%20%20let%20accountNumber%20%3D%20account.querySelectorAll('div%3Ediv')%5B1%5D.textContent.split(%22%20%22)%5B0%5D%0A%0A%20%20%20%20for%20(let%20accessLevel%20of%20accessLevels)%20%7B%0A%20%20%20%20%20%20%20%20profileBody%20%2B%3D%20%60%5Bprofile%20%24%7BaccountName%7D-%24%7BaccountNumber%7D-%24%7BaccessLevel.replace(%2F_%2Fg%2C%20'-')%7D%5D%0Asso_account_id%3D%24%7BaccountNumber%7D%0Aregion%3D%24%7Bregion%7D%0Asso_session%3Dcli-access%0Asso_region%3Dus-west-2%0Asso_role_name%3D%24%7BaccessLevel%7D%0Asso_start_url%3Dhttps%3A%2F%2Fd-92671f41c2.awsapps.com%2Fstart%23%0A%0A%60%0A%20%20%20%20%7D%0A%7D)%0A%0A%0Aif%20(document.querySelector('%23awsConfig'))%20%7B%0A%20%20%20%20document.querySelector('%23awsConfig').remove()%0A%7D%0Awrapper%20%3D%20document.createElement(%22div%22)%0Awrapper.setAttribute('id'%2C%20'awsConfig')%0Awrapper.style.padding%20%3D%20'10px'%0Adocument.getElementById('content-wrapper').appendChild(wrapper)%0A%0Aelem%20%3D%20document.createElement(%22pre%22)%0Aelem.setAttribute('id'%2C%20'awsProfiles')%0Aelem.textContent%20%3D%20profileBody%0Adocument.getElementById('awsConfig').appendChild(elem)%0A%0Abtn%20%3D%20document.createElement(%22button%22)%0Abtn.setAttribute('id'%2C%20'copyButton')%0A%0Abtn.textContent%20%3D%20%22Copy%20to%20clipboard%22%0Abtn.style.position%20%3D%20'absolute'%0Abtn.style.top%20%3D%20'5px'%0Abtn.style.right%20%3D%20'5px'%0Abtn.style.zIndex%20%3D%20'10000'%0Abtn.style.backgroundColor%20%3D%20%22green%22%0Abtn.onclick%20%3D%20function%20()%20%7B%0A%20%20%20%20navigator.clipboard.writeText(profileBody)%0A%20%20%20%20alert('Copied%20to%20clipboard')%0A%7D%0Adocument.getElementById('awsConfig').appendChild(btn)%7D)()%3B
```