# TYPO3 Neos | Abstract Docker image

This is a Docker image which is designed to easily create images with standard or customised [TYPO3 Neos] setup. It is available in Docker Hub as [million12/typo3-neos-abstract](https://registry.hub.docker.com/u/million12/typo3-neos-abstract).

An example of working TYPO3 Neos image built on top of this one, see [million12/typo3-neos](https://registry.hub.docker.com/u/million12/typo3-neos).

The image is designed that as a result, after running a container from it, you'll get working TYPO3 Neos in a few seconds. When the image is being build, it pre-installs requested version of TYPO3 Neos. When container is launched, it will initialise and configure pre-installed package. Nginx vhosts will be set, Settings.yaml will be updated with database credentials (to linked db container), initial Neos admin user will be created and site package will be imported. Read below about available ENV variables to customise your setup.

## Usage

As it's shown in [million12/typo3-neos](https://github.com/million12/docker-typo3-neos), you can build your own TYPO3 Neos image with following Dockerfile:

```
FROM million12/typo3-neos-abstract:latest

# ENV: Install following TYPO3 Neos version
ENV TYPO3_NEOS_VERSION 1.1.2

# ENV: Repository for installed TYPO3 Neos distribution 
#ENV TYPO3_NEOS_REPO_URL git://git.typo3.org/Neos/Distributions/Base.git

# ENV: Optional composer install parameters
#ENV TYPO3_NEOS_COMPOSER_PARAMS --dev --prefer-source

#
# Pre-install TYPO3 Neos into /tmp/typo3-neos.tgz
#
RUN . /build-typo3-neos/pre-install-typo3-neos.sh
```

This will pre-install default TYPO3 Neos distribution, version 1.1.2. Uncomment and provide custom `ENV TYPO3_NEOS_REPO_URL` to install your own distribution.

See [README.md](https://github.com/million12/docker-typo3-neos/README.md) from [million12/typo3-neos](https://github.com/million12/docker-typo3-neos) for information how you can launch complete setup.


## How does it work

During *build process* of your image (based on this one), TYPO3 Neos will be pre-installed via composer install and embedded inside final image. Using ENV variables (listed below) you can install custom distribution (e.g. from GitHub repo) and selected version of TYPO3 Neos. See [pre-install-typo3-neos.sh](container-files/build-typo3-neos/pre-install-typo3-neos.sh) for details. Next, when the container is launched, it will do all necessary steps to make it up & running. Script [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) will set up Nginx vhost config, supply Settings.yaml with database credentials (using linked DB container), and - if it's empty database - do doctrine migration, set admin user and import initial site package. You can fully customise all details via ENV variables.  
 
## Customise

### Dockerfile

In Dockerfile you can customise what and from where is pre-installed during build stage:   
```
FROM million12/typo3-neos-abstract:latest

# ENV: Install custom Neos version
# Default: master
ENV TYPO3_NEOS_VERSION 1.1.2

# ENV: Repository for installed TYPO3 Neos distribution
# Default: git://git.typo3.org/Neos/Distributions/Base.git
ENV TYPO3_NEOS_REPO_URL https://github.com/you/your-typo3-neos-distro.git

# ENV: Custom composer install params
# Default: --dev --prefer-source
ENV TYPO3_NEOS_COMPOSER_PARAMS --no-dev --prefer-dist --optimize-autoloader

# Run pre-install script
RUN . /build-typo3-neos/pre-install-typo3-neos.sh
```

### Runtime variables

The following are ENV variables which can be overridden when container is launched (via --env). You can also embed them in your Dockerfile. See [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) where they are defined with their default values. 

**NEOS_APP_NAME**  
Default: `NEOS_APP_NAME=${NEOS_APP_NAME:="neos"}`  
Used internally as a folder name in /data/www/NEOS_APP_NAME where Neos will be installed and it's used in default vhost name.

**NEOS_APP_DB_NAME**  
Default: `NEOS_APP_DB_NAME=${NEOS_APP_DB_NAME:="typo3_neos"}`  
Database name, which will be used for TYPO3 Neos. It will be created and migrated, if it doesn't exist.

**NEOS_APP_USER_NAME, NEOS_APP_USER_PASS, NEOS_APP_USER_FNAME, NEOS_APP_USER_LNAME**
Default: `NEOS_APP_USER_NAME=${NEOS_APP_USER_NAME:="admin"}`  
Default: `NEOS_APP_USER_PASS=${NEOS_APP_USER_PASS:="password"}`  
Default: `NEOS_APP_USER_FNAME=${NEOS_APP_USER_FNAME:="Admin"}`  
Default: `NEOS_APP_USER_LNAME=${NEOS_APP_USER_LNAME:="User"}`
If this is fresh installation, admin user will be created with above details.

**NEOS_APP_VHOST_NAMES**  
Default: `**NEOS_APP_VHOST_NAMES=${NEOS_APP_VHOST_NAMES:="${NEOS_APP_NAME} dev.${NEOS_APP_NAME} test.${NEOS_APP_NAME}"}`
Hostname(s) to configure in Nginx. Nginx is configured that it will set `FLOW_CONTEXT` to *Development* if it contains *dev* in its name, *Testing* if it contains *test*.

**NEOS_APP_SITE_PACKAGE**  
Default: `NEOS_APP_SITE_PACKAGE=${NEOS_APP_SITE_PACKAGE:="TYPO3.NeosDemoTypo3Org"}`
If you pre-installed custom TYPO3 Neos distribution, you'll probably want to replace this with your own site package available there. This site package will be installed and its content imported, if it's fresh install.

### Custom build steps

You might want to add extra steps to the standard ones provided by [configure-typo3-neos.sh](container-files/build-typo3-neos/configure-typo3-neos.sh) script. This script is invoked from [/config/init/20-init-typo3-neos-app](config/init/20-init-typo3-neos-app) - all scripts available there are run when container starts. Therefore you can add there your own, simply via `ADD custom-init.sh /config/init/` in your Dockerfile.


## Authors

Author: Marcin Ryzycki (<marcin@m12.io>)  
