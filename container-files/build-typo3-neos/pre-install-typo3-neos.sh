#!/bin/sh

#
# Pre-install TYPO3 Neos from $TYPO3_NEOS_REPO_URL
# into archived package in /tmp/typo3-neos.tgz.
#
# This archive will be then used when container starts for the 1st time.
# We do that to avoid installing Neos during runtime, which is slow
# and potentially error-prone (i.e. composer conflicts/timeouts etc).
#

set -e
set -u

#
# ENV variables: override them if needed
#
TYPO3_NEOS_REPO_URL=${TYPO3_NEOS_REPO_URL:="git://git.typo3.org/Neos/Distributions/Base.git"}
TYPO3_NEOS_VERSION=${TYPO3_NEOS_VERSION:="master"}
TYPO3_NEOS_COMPOSER_PARAMS=${TYPO3_NEOS_COMPOSER_PARAMS:="--dev --prefer-source"}
#
# ENV variables (end)
#

echo
echo "Installing TYPO3 Neos *$TYPO3_NEOS_VERSION* from $TYPO3_NEOS_REPO_URL repository."
echo

# Clone Neos distribution from provided repository
git clone $TYPO3_NEOS_REPO_URL /tmp/typo3-neos
cd /tmp/typo3-neos

# Do composer install
git checkout $TYPO3_NEOS_VERSION
COMPOSER_PROCESS_TIMEOUT=900 composer install $TYPO3_NEOS_COMPOSER_PARAMS

# Prepare tar archive
cd /tmp && tar -zcf typo3-neos.tgz ./typo3-neos 
rm -rf /tmp/typo3-neos # Save container space by keeping only .tgz archive

echo
echo "TYPO3 Neos $TYPO3_NEOS_VERSION installed."
echo $(ls -lh /tmp/)
echo 
