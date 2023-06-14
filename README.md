# Docker to Azure VM

GitHub action to deploy any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an Azure VM using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker-compose up`.

## Getting Started Intro Video

_Coming Soon_

## Requirements

1. Files for Docker
2. An Azure account

### 1. Files for Docker

Your app needs a `Dockerfile` and a `docker-compose.yaml` file.

> For more details on setting up Docker and Docker Compose, check out Bitovi's Academy Course: [Learn Docker](https://www.bitovi.com/academy/learn-docker.html)

### 2. An Azure account

You'll need Access Secrets from an Azure account. The best documentation on how to get started from a command-line perspective is here: https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli and https://learn.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli

## Environment variables

For environment variables in your app, you can provide:

- `repo_env` - A file in your repo that contains env vars
- `ghv_env` - An entry in [Github actions variables](https://docs.github.com/en/actions/learn-github-actions/variables)
- `dot_env` - An entry in [Github secrets](https://docs.github.com/es/actions/security-guides/encrypted-secrets)
- `Azure_secret_env` - The path to a JSON format secret in Azure

Then hook it up in your `docker-compose.yaml` file like:

```yaml
version: '3.9'
services:
  app:
    env_file: .env
```

These environment variables are merged to the .env file quoted in the following order:

- Terraform passed env vars ( This is not optional nor customizable )
- Repository checked-in env vars - repo_env file as default. (KEY=VALUE style)
- Github Secret - Create a secret named DOT_ENV - (KEY=VALUE style)
- Azure Secret - JSON style like '{"key":"value"}'

## Example usage

Create `.github/workflow/deploy.yaml` with the following to build on push:

### Basic example

```yaml
name: Basic deploy
on:
  push:
    branches: [ main ]

jobs:
  Deploy:
    runs-on: ubuntu-latest
    steps:
      - id: deploy
        uses: bitovi/github-actions-docker-to-azure-vm@v1
        with:
          AZURE_ARM_CLIENT_ID: ${{ secrets.AZURE_ARM_CLIENT_ID }}
          AZURE_ARM_CLIENT_SECRET: ${{ secrets.AZURE_ARM_CLIENT_SECRET }}
          AZURE_ARM_TENANT_ID: ${{ secrets.AZURE_ARM_TENANT_ID }}
          AZURE_ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_ARM_SUBSCRIPTION_ID }}
          azure_resource_identifier: 'my-resource-group'
          AZURE_STORAGE_ACCOUNT: 'mystorageaccount'
          tf_state_bucket: 'my-state-bucket'
          stack_destroy: 'false'
```

### Advanced example

```yaml
name: Advanced deploy
on:
  push:
    branches: [ main ]

permissions:
  contents: read

jobs:
  EC2-Deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ github.ref_name }}
      url: ${{ steps.deploy.outputs.vm_url }}
    steps:
    - id: deploy
      name: Deploy
      uses: bitovi/github-actions-docker-to-azure-vm@v1
      with:
        AZURE_ARM_CLIENT_ID: ${{ secrets.AZURE_ARM_CLIENT_ID }}
        AZURE_ARM_CLIENT_SECRET: ${{ secrets.AZURE_ARM_CLIENT_SECRET }}
        AZURE_ARM_TENANT_ID: ${{ secrets.AZURE_ARM_TENANT_ID }}
        AZURE_ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_ARM_SUBSCRIPTION_ID }}
        Azure_default_region: eastus
        tf_state_bucket: 'my-state-bucket'
        dot_env: ${{ secrets.DOT_ENV }}
        ghv_env: ${{ vars.VARS }}
        app_port: 3000
        additional_tags: "{\"key1\": \"value1\",\"key2\": \"value2\"}"
```

## Need help or have questions?

This project is supported by [Bitovi, a DevOps Consultancy](https://www.bitovi.com/devops-consulting) and a proud supporter of Open Source software.

You can **get help or ask questions** on our [Discord channel](https://discord.gg/J7ejFsZnJ4)! Come hang out with us!

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/devops-consulting).

## Made with BitOps

[BitOps](https://bitops.sh) allows you to define Infrastructure-as-Code for multiple tools in a central place.  This action uses a BitOps [Operations Repository](https://bitops.sh/operations-repo-structure/) to set up the necessary Terraform and Ansible to create infrastructure and deploy to it.

## Contributing

We would love for you to contribute to this repo!

Would you like to see additional features?  [Create an issue](https://github.com/bitovi/github-actions-docker-to-azure-vm/issues/new) or feel free to branch and submit a PR! We love discussing newsolutions!

## License

The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/main/LICENSE).
