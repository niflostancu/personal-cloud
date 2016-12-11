#!/usr/bin/env php
<?php
$confpath = '/var/www/rss/config.php';

if (file_exists($confpath)) {
	include($confpath);
} else {
	error("Invalid configuration file: $confpath");
}

$config = array(
	'DB_TYPE' => DB_TYPE,
	'DB_HOST' => DB_HOST,
	'DB_USER' => DB_USER,
	'DB_NAME' => DB_NAME,
	'DB_PASS' => DB_PASS,
	'DB_PORT' => DB_PORT,
);

if (empty($config['DB_PORT'])) {
	$config['DB_PORT'] = ($config['DB_TYPE'] == 'pgsql' ? 5432 : 3306);
}

// database credentials for this instance
if (!dbcheck($config)) {
	echo 'Database login failed, trying to create...' . PHP_EOL;
	// superuser account to create new database and corresponding user account
	//   username (SU_USER) can be supplied or defaults to "root"
	//   password (SU_PASS) can be supplied or defaults to username
	$super = $config;
	$super['DB_NAME'] = null;
	$super['DB_USER'] = env('DB_SU_USER', 'root');
	$super['DB_PASS'] = env('DB_SU_PASS', '');

	$pdo = dbconnect($super);
	if ($super['DB_TYPE'] === 'mysql') {
		$pdo->exec('CREATE DATABASE ' . ($config['DB_NAME']));
		$pdo->exec('GRANT ALL PRIVILEGES ON ' . ($config['DB_NAME']) . '.* TO ' . $pdo->quote($config['DB_USER']) . '@"%" IDENTIFIED BY ' . $pdo->quote($config['DB_PASS']));
	} else {
		$pdo->exec('CREATE ROLE ' . ($config['DB_USER']) . ' WITH LOGIN PASSWORD ' . $pdo->quote($config['DB_PASS']));
		$pdo->exec('CREATE DATABASE ' . ($config['DB_NAME']) . ' WITH OWNER ' . ($config['DB_USER']));
	}
	unset($pdo);

	if (dbcheck($config)) {
		echo 'Database login created and confirmed' . PHP_EOL;
	} else {
		error('Database login failed, trying to create login failed as well');
	}
}

$pdo = dbconnect($config);
try {
	$pdo->query('SELECT 1 FROM ttrss_feeds');
	// reached this point => table found, assume db is complete
}
catch (PDOException $e) {
	echo 'Database table not found, applying schema... ' . PHP_EOL;
	$schema = file_get_contents('/var/www/rss/schema/ttrss_schema_' . $config['DB_TYPE'] . '.sql');
	$schema = preg_replace('/--(.*?);/', '', $schema);
	$schema = preg_replace('/[\r\n]/', ' ', $schema);
	$schema = trim($schema, ' ;');
	foreach (explode(';', $schema) as $stm) {
		$pdo->exec($stm);
	}
	unset($pdo);
}

// utility functions
function env($name, $default = null)
{
	$v = getenv($name) ?: $default;

	if ($v === null) {
		error('The env ' . $name . ' does not exist');
	}

	return $v;
}

function error($text)
{
	fwrite(STDERR, 'Error: ' . $text . PHP_EOL);
	exit(1);
}

function dbconnect($config)
{
	$map = array('host' => 'HOST', 'port' => 'PORT', 'dbname' => 'NAME');
	$dsn = $config['DB_TYPE'] . ':';
	foreach ($map as $d => $h) {
		if (isset($config['DB_' . $h])) {
			$dsn .= $d . '=' . $config['DB_' . $h] . ';';
		}
	}
	$pdo = new \PDO($dsn, $config['DB_USER'], $config['DB_PASS']);
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	return $pdo;
}

function dbcheck($config)
{
	try {
		dbconnect($config);
		return true;
	}
	catch (PDOException $e) {
		return false;
	}
}


