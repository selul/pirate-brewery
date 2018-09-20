# WordPress with ThemeIsle Development Environment
# Docker Hub: https://hub.docker.com/r/hardeepasrani/pirate-brewery/
# Github Repo: https://github.com/HardeepAsrani/pirate-brewery/

# Use WordPress as the base image
FROM wordpress:latest

# Copy wp-su.sh
COPY wp-su.sh /bin/wp

# Copy entrypoint
COPY docker-pirate-entrypoint.sh /usr/local/bin/

# Setup ThemeIsle Development Environment
RUN apt-get update \
	# Install required packages
	&& apt-get install -y --no-install-recommends sudo less wget mysql-client gnupg gnupg2 gnupg1 git subversion \
	# Install WP-CLI
	&& curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /bin/wp-cli.phar /bin/wp \
	# Install NodeJS and npm
	&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
	&& apt-get install -y nodejs \
	# Install PHP CodeSniffer
	&& pear install PHP_CodeSniffer \
	# Install WordPress Codeing Standards
	&& git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git wpcs \
	&& mv wpcs /bin/wpcs \
	&& phpcs --config-set installed_paths /bin/wpcs/ \
	&& pear upgrade PHP_CodeSniffer \
	# Install Grunt and GruntCLI
	&& npm install -g grunt grunt-cli \
	# Install Composer
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv /var/www/html/composer.phar /bin/composer \
	# Install PHPUnit
	&& wget https://phar.phpunit.de/phpunit-6.5.phar \
	&& chmod +x phpunit-6.5.phar \
	&& mv phpunit-6.5.phar /bin/phpunit \
	# Checkout WordPress' PHP Unit Files
	&& mkdir /tmp/wordpress-tests-lib/ \
	&& svn checkout https://develop.svn.wordpress.org/trunk/tests/phpunit/includes/ /tmp/wordpress-tests-lib/includes/ \
	&& svn checkout https://develop.svn.wordpress.org/trunk/tests/phpunit/data/ /tmp/wordpress-tests-lib/data/ \
	&& curl -O https://develop.svn.wordpress.org/trunk/wp-tests-config-sample.php  \
	&& mv wp-tests-config-sample.php /tmp/wordpress-tests-lib/wp-tests-config-sample.php \
	# Remove unuseable packages
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/pear /var/tmp/*

# Setup Entrypoint
ENTRYPOINT [ "docker-pirate-entrypoint.sh" ]

# Start Apache Process
CMD [ "apache2-foreground" ]