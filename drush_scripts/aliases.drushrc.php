<?php
/*UI TO UX styled - Aliases*/
$aliases = array();
$multisite_installations = array(
        '/home/dadesigners/vhosts/dadesigners.com/httpdocs',
        '/home/dadesigners/vhosts/iamsenor.com/httpdocs'
);

foreach($multisite_installations as $drupal_root) {
        $sites_root = $drupal_root.'/sites';
        $exceptions = array('.', '..', 'all', 'default');

        $directory = new DirectoryIterator($sites_root);
        foreach($directory as $file) {
                $fileName = $file->getFilename();
                if(!empty($fileName) && !in_array($fileName, $exceptions)) {
                        $aliases[$fileName] = array(
                                'root' => $drupal_root,
                                'uri' => $fileName
                        );
                }
        }
}
