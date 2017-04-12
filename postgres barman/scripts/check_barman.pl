#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Config::Tiny;
use Time::Local;
use Getopt::Long;
use Switch;

my $first = 1;
my $opt_debug;
my $debug;
GetOptions(
	"debug|d" => \$debug
);

# read the zabbix hostname
my $zabbix = Config::Tiny->new;
$zabbix = Config::Tiny->read( '/etc/zabbix/zabbix_agentd.conf' );
my $zabbix_hostname = $zabbix->{_}->{Hostname};

my $hash_postgres_server;
my $hash_data;

# discover all backup server and generated a hash
print "$zabbix_hostname discover.postgres.server {";
print " \"data\":[";
	
	for (`barman list-server --minimal`) {
		chomp($_);
		my $postgres_server = $_;
		$hash_postgres_server -> {"$postgres_server"} = {} unless exists($hash_postgres_server -> {"$postgres_server"});
		print "," if not $first;
		$first = 0;
		print " { \"{#POSTGRES.SERVER}\":\"$postgres_server\" }";
	}
	
print " ] }\n";

print "Dump hash_postgres_server" . Dumper($hash_postgres_server) if($debug);

my $backup_type = "";
foreach my $postgres_server(sort (keys %$hash_postgres_server)){
	my $cmd = "barman show-backup $postgres_server latest 2>&1";
	for (`$cmd`) {
		chomp($_);
		my $line = $_;
		if($line =~ /Status\s+:\s+(.*)/){
			(my $key = $1) =~ s/\s+//g;
			print "$zabbix_hostname Status.[\'$postgres_server\'] $key\n";
		}
		if($line =~ /\s+(.*)\s+information:/){
			($backup_type = $1) =~ s/\s+/_/g;
		}

		if(($backup_type eq "Base_backup") or ($backup_type eq "WAL")){
			if($line =~ /Disk usage\s+:\s+([\d+|.]*)\s+(\w+)/){
				my $unit = $2;
				(my $key = $1) =~ s/\s+//g;
				
				my $number = _convert_unit('unit' => $unit,'number' => $key);
			
				print "$zabbix_hostname Disk.$backup_type.usage.['$postgres_server\'] $number\n";
			}
			if(($backup_type eq "Base_backup") ){
				if($line =~ /Begin time\s+:\s+(....)-(..)-(..)\s+(..):(..):(..)/){
						#2017-04-09 22:33:02+02:00
						#timelocal( $sec, $min, $hour, $mday, $mon, $year );
						my $date = timelocal($6,$5,$4,$3,$2-1,$1);
						print "$zabbix_hostname Previous.Backup.[\'$postgres_server\'] $date\n";
				}
			}
		}
	}
}

foreach my $postgres_server(sort (keys %$hash_postgres_server)){
	my $cmd = "barman check $postgres_server";
	for (`$cmd`) {
		chomp($_);
		my $line = $_;
		
		my ($key,$value);
		if($line =~ /.*\(.*\)/){
			if($line =~ /\s+(.*):\s+(.*)\s+\(/){
				$key = $1;
				$value = $2;
			}
		} else {
			if($line =~ /\s+(.*):\s+(.*)/){
				$key = $1;
				$value = $2;
			}
		}

		if(($key) and ($value)){
			(my $ITEM_NAME = $key) =~ s/\s+/./g;
			my $ITEM_KEY = $postgres_server.".".$ITEM_NAME;
			$ITEM_NAME = $postgres_server.".".$ITEM_NAME;
			my $data = '{ "{#ITEM_NAME}":"'.$ITEM_NAME.'","{#ITEM_KEY}":"'.$ITEM_KEY.'" }';
			
			# generated a hash of all items from barman check
			$hash_data -> {"$ITEM_KEY"} = {} unless exists($hash_data -> {"$ITEM_KEY"});
			$hash_data -> {"$ITEM_KEY"} = {
				"data" => "$data",
				"value" => "$value",
			};
		}
	}
}

print "Dump hash_data" . Dumper($hash_data) if($debug);

# print out the discover itmes from barman check
print $zabbix_hostname.' discover.check.server { "data":[ ';
	my $data = "";
	my $sum_data = "";
	foreach my $ITEM_KEY(sort (keys %$hash_data)){
		$data = $hash_data -> {"$ITEM_KEY"}-> {"data"};
		if($data){
			$sum_data = $data ."," . $sum_data;
		}
	}
	$sum_data =~ s/,$//;
	print $sum_data;
print ' ] }'."\n";


#send the key / value
foreach my $ITEM_KEY(sort (keys %$hash_data)){
	my $value = $hash_data -> {"$ITEM_KEY"}-> {"value"};

	print "$zabbix_hostname check.\[\'$ITEM_KEY\'\] $value\n";
}

sub _convert_unit{
	my %arg = @_;
	my $unit = $arg{'unit'};
	my $number = $arg{'number'};
	if(($unit) and ($number)){
		switch($unit) {
			case "KiB" { $number = $number * 1024 }
			case "MiB" { $number = $number * 1024 * 1024 }
			case "GiB" { $number = $number * 1024 * 1024 * 1024}
			case "TiB" { $number = $number * 1024 * 1024 * 1024 * 1024}
		}
	}
	return $number;
}
#print Dumper($hash_data);
