# dotnet-sql-dev

A simple example of a .NET 5.0 container development environment for VSCode
with a related SQL Server 2019 container

## Installation

Download and unpack or `git clone` this repo to a folder of your choosing.

## Usage

Ctrl-Shift-P (or F1) and then `Remote Containers: Open Folder in Container...`
choosing the folder where you unpacked or cloned this repo.

The files of interest are in the `.devcontainer` folder:

- [`devcontainer.json`](.devcontainer/devcontainer.json): VSCode's container configuration for the development environment (the container within which VSCode will run). See [Microsoft's devcontainer.json reference](https://code.visualstudio.com/docs/remote/devcontainerjson-reference) for more details. Most importanly, this file includes the VSCode extensions that should be installed in the container.
- [`docker-compose.yml`](.devcontainer/docker-compose.yml): a standard [docker-compose](https://docs.docker.com/compose/) file for configuring one or multiple containers, designating images, Dockerfiles, etc. See [the docker-compose file reference](https://docs.docker.com/compose/compose-file/) for more details.
- [`Dockerfile`](.devcontainer/Dockerfile): defines a base image and customizations for the development container. See [the Dockerfile reference](https://docs.docker.com/engine/reference/builder/) for more details.
- [`dev-setup.sh`](.devcontainer/dev-setup.sh): a [Bash](https://learnxinyminutes.com/docs/bash/) script called by the Dockerfile that installs and configures packages in the development container.

Please note that all of the above only engage the _development_ container. You may also want to build a container image for testing and deployment as part of the project. See [ASP.NET Core in a Container](https://code.visualstudio.com/docs/containers/quickstart-aspnet-core) for an example, although, given the above, you would not need to install .NET or C# locally, as it is already in the development container. The development container _builds_, and the application contain is _built_.

To begin building an ASP.NET app, for instance, you might try:

- Launch the VSCode terminal (Ctrl-Shift-\`), then `dotnet new webapi --no-https`
- In VSCode, Ctrl-Shift-P then `.NET: Generate Assets for Build and Debug`
- For some reason, I needed to restart VSCode after the above.
- In VSCode, Ctrl-Shift-P then `Docker: Add Docker Files to Workspace...`, then `.NET: ASP.NET Core`, then `Linux`, then `5000`. I select `Yes` to generate the Docker Compose files, but this is not necessary if you only need a Dockerfile.

For a decent introduction to developing inside a container with VSCode, see [this article](https://code.visualstudio.com/docs/remote/create-dev-container).

## Contributing

Please open an issue to suggest changes.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE.md)
