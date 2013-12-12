# www to non-www redirect -- duplicate content is BAD:
# https://github.com/h5bp/html5-boilerplate/blob/5370479476dceae7cc3ea105946536d6bc0ee468/.htaccess#L362
# Choose between www and non-www, listen on the *wrong* one and redirect to
# the right one -- http://wiki.nginx.org/Pitfalls#Server_Name
server {
  # don't forget to tell on which port this server listens
  listen 80;

  # listen on the www host
  server_name www.example.com;

  # and redirect to the non-www host (declared below)
  return 301 $scheme://example.com$request_uri;
}

server {
	# listen 80 deferred; # for Linux
	# listen 80 accept_filter=httpready; # for FreeBSD
	listen 80;

	# Make site accessible from http://localhost/
	server_name example.com;

	root /var/www/example.com;
	index index.html index.htm index.php;

	# Specific logs for this vhost
	access_log /var/log/nginx/example.com-access.log;
	error_log  /var/log/nginx/example.com-error.log error;

	# Specify a character set
	charset utf-8;

	# h5bp nginx configs
	include h5bp/basic.conf;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ /index.php?q=$uri&$args;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

	# Don't log robots.txt or favicon.ico files
	location = /favicon.ico { log_not_found off; access_log off; }
	location = /robots.txt  { access_log off; log_not_found off; }

	error_page 404 /404.html;

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
	#	# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
	#
	#	# With php5-cgi alone:
	#	fastcgi_pass 127.0.0.1:9000;
	#	# With php5-fpm:
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	location ~ /\.ht {
		deny all;
	}
}


# another virtual host using mix of IP-, name-, and port-based configuration
#
#server {
#	listen 8000;
#	listen somename:8080;
#	server_name somename alias another.alias;
#	root html;
#	index index.html index.htm;
#
#	location / {
#		try_files $uri $uri/ =404;
#	}
#}


# HTTPS server
#
#server {
#	listen 443;
#	server_name localhost;
#
#	root html;
#	index index.html index.htm;
#
#	ssl on;
#	ssl_certificate cert.pem;
#	ssl_certificate_key cert.key;
#
#	ssl_session_timeout 5m;
#
#	ssl_protocols SSLv3 TLSv1;
#	ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
#	ssl_prefer_server_ciphers on;
#
#	location / {
#		try_files $uri $uri/ =404;
#	}
#}
