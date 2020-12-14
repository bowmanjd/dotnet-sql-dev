#!/usr/bin/bash

set -e

PACKAGE_LIST=" \
        apt-transport-https \
        ca-certificates \
        curl \
        docker-ce-cli \
        git \
        gnupg2 \
        mssql-tools \
        sudo \
        unixodbc-dev \
        "

export DEBIAN_FRONTEND=noninteractive
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

echo "Installing apt-utils"
apt-get install apt-utils

# Read OS version vars
source /etc/os-release

echo "Adding official Docker package sources"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list

echo "Adding official Microsoft package sources"
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl -o /etc/apt/sources.list.d/msprod.list "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/prod.list"

echo "Updating package repo, upgrading, and installing packages"
apt-get update
apt-get -y upgrade --no-install-recommends
ACCEPT_EULA=Y apt-get -y install --no-install-recommends ${PACKAGE_LIST}
apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Basic setup of user, etc.
#echo "Setting up user \"${USERNAME}\""
#groupadd --gid $USER_GID $USERNAME
#useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
echo "Configuring sudo access for user \"${USERNAME}\""
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${SOURCE_SOCKET}" "${TARGET_SOCKET}" "${USERNAME}" \
echo "Adding MS SQL tools to PATH"
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> "/home/${USERNAME}/.bashrc"

echo "Installing latest docker-compose"
LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")')
curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Linking ${SOURCE_SOCKET} and ${TARGET_SOCKET}"
if [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ]; then
    touch "${SOURCE_SOCKET}"
    ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"
fi

# If enabling non-root access and specified user is found, setup socat and add script
chown -h "${USERNAME}":root "${TARGET_SOCKET}"        
tee /usr/local/share/docker-init.sh > /dev/null \
<< EOF 
#!/usr/bin/env bash

set -e

SOCKET_GID=\$(stat -c '%g' ${SOURCE_SOCKET})
if [ "\$(cat /etc/group | grep :\${SOCKET_GID}:)" = "" ]; then
    sudo groupadd --gid \${SOCKET_GID} docker-host
fi
if [ "\$(id ${USERNAME} | grep -E 'groups=.+\${SOCKET_GID}\(')" = "" ]; then
    sudo usermod -aG \${SOCKET_GID} ${USERNAME}
fi

set +e
exec "\$@"
EOF
chmod +x /usr/local/share/docker-init.sh
chown ${USERNAME}:root /usr/local/share/docker-init.sh


echo "Done!"