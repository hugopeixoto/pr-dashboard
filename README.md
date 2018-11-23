## Usage

- Get an access token from github: `Settings > Developer settings > Personal access tokens`
- Paste it into `secret.txt`
- Run the following:
  ```bash
  ruby prs.rb "$(cat secret.txt)" "ORGANIZATION_NAME" | ruby prs2html.rb > prs.html
  ```
