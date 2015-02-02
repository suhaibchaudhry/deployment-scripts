server {
     listen 80;
     listen 7575;

     server_name uitoux.com www.uitoux.com;

     location / {
          root /home/uitoux/uitoux.com/httpdocs;
          index index.php index.html index.htm;
          try_files $uri $uri/ @rewrite;
          disable_symlinks off;
          autoindex on;
     }

     location @rewrite {
          rewrite ^/(.*)$ /index.php?q=$1;
     }

     location ~ ^/sites/.*/files/styles/ {
          try_files $uri @rewrite;
     }

     location ~ \.php$ {
         try_files $uri = 404;
         fastcgi_split_path_info ^(.+\.php)(.*)$;
         fastcgi_pass unix:/var/run/php5-fpm.sock;
         fastcgi_index index.php;
         fastcgi_param SCRIPT_FILENAME /home/uitoux/uitoux.com/httpdocs$fastcgi_script_name;
         root /home/uitoux/uitoux.com/httpdocs;
         include fastcgi_params;
         fastcgi_param QUERY_STRING $query_string;
         fastcgi_param PATH_INFO $fastcgi_path_info;
         fastcgi_param REQUEST_METHOD $request_method;
         fastcgi_param CONTENT_TYPE $content_type;
         fastcgi_param CONTENT_LENGTH $content_length;
         fastcgi_intercept_errors on;
         fastcgi_ignore_client_abort off;
         fastcgi_connect_timeout 60;
         fastcgi_send_timeout 180;
         fastcgi_read_timeout 180;
         fastcgi_buffer_size 128k;
         fastcgi_buffers 4 256k;
         fastcgi_busy_buffers_size 256k;
         fastcgi_temp_file_write_size 256k;
     }

     location ~ /\.ht {
          deny all;
     }
}
