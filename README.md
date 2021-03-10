# action-hub@sync-2-gitee

![](https://img.shields.io/github/license/shink/bark-action.svg)
![](https://img.shields.io/badge/language-shell-89E051.svg)

An action for [action-hub@sync-2-gitee](https://github.com/Forest10/actions-hub)


## Usage

```yml
name: sync-2-gitee
on:
  push:
    branches:
      - hexo-upyun
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: action-hub@sync-2-gitee
        uses: Forest10/actions-hub@v1.0.3
        env:
          ## github info
          GITHUB_REPOSITORY: Forest10/testSync
          PRIVATE_GITHUB_TOKEN: ${{ secrets.PRIVATE_GITHUB_TOKEN }}
          ## gitee info
          GITEE_USERNAME: Forest10
          GITEE_HTTPS_REF: gitee.com/Forest10/testSync.git
          GITEE_TOKEN: ${{ secrets.GITEE_TOKEN }}
```

> Among them, only the `key` parameter is required

- `GITHUB_REPOSITORY`: like Forest10/test(without .git)
- `PRIVATE_GITHUB_TOKEN`: PRIVATE_GITHUB_TOKEN IN YOUR secrets
- `GITEE_USERNAME`: Your gitee UserName
- `GITEE_HTTPS_REF`: Your gitee repository url. like gitee.com/Forest10/testSync(without https ahead and  .git end)
- `GITEE_TOKEN`: GITEE_TOKEN IN YOUR secrets
## License

[MIT](LICENSE)
