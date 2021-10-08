#!/bin/sh
set -eu

echo "λλλ checkout master branch"
git checkout master

echo "λλλ read current PHP CS Fixer version"
./extractor.php | jq .version
CURRENT_PHP_CS_FIXER_VERSION=$(./extractor.php | jq -r .version.number)
CURRENT_PHP_CS_FIXER_CODENAME=$(./extractor.php | jq -r .version.codename)
echo "Current PHP CS Fixer version number: ${CURRENT_PHP_CS_FIXER_VERSION}"
echo "Current PHP CS Fixer version codename: ${CURRENT_PHP_CS_FIXER_CODENAME}"


echo "λλλ get newest PHP CS Fixer version"
php php-cs-fixer.phar self-update || curl --silent --fail -L "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/$(curl --silent --fail -u keradus:5e7538aa415005c606ea68de2bbbade0409b4b8c https://api.github.com/repos/FriendsOfPHP/PHP-CS-Fixer/releases/latest | jq -r .tag_name)/php-cs-fixer.phar" -o php-cs-fixer-v3.phar


echo "λλλ read newest PHP CS Fixer version"
./extractor.php | jq .version
NEW_PHP_CS_FIXER_VERSION=$(./extractor.php | jq -r .version.number)
NEW_PHP_CS_FIXER_CODENAME=$(./extractor.php | jq -r .version.codename)
echo "New PHP CS Fixer version number: ${NEW_PHP_CS_FIXER_VERSION}"
echo "New PHP CS Fixer version codename: ${NEW_PHP_CS_FIXER_CODENAME}"

if [ "$CURRENT_PHP_CS_FIXER_VERSION" = "$NEW_PHP_CS_FIXER_VERSION" ]; then
    echo "λλλ Versions are identical"
else
    echo "λλλ New version found"
    git config user.name "GitHub Actions Bot"
    git config user.email "<>"
    echo "λλλ Committing and tagging release $NEW_PHP_CS_FIXER_VERSION"
    git add php-cs-fixer.phar
    git commit -m "Upgrade to $NEW_PHP_CS_FIXER_VERSION"
    git push origin master
    git tag v${NEW_PHP_CS_FIXER_VERSION}
    git push --tags
fi

echo "λλλ done"
