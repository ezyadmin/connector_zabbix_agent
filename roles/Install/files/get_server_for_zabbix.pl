#!/usr/bin/perl

# ========== Map Service =======================
my %SERVICE = (
    "Linux" => "00",
    "httpd" => "01",
    "exim" => "02",
    "mysql" => "03",
    "sshd" => "04",
    "dovecot" => "05",
    "pure-ftpd" => "06",
    "cpanel" => "07",
    "logsurfer" => "08",
    "named" => "09",
    "cagefs" => "10",
    "csf" => "11",
    "lfd" => "12",
    "DCC" => "13",
    "lve" => "14",
    "lvectl" => "15",
    "lvestats" => "16",
    "mdmonitor" => "17",
    "Windows" => "18",
    "iis" => "19",
    "mysqld" => "20",
    "W3SVC" => "21",
    "ftpsvc" => "22",
    "MsMpSvc" => "23",
    "WinDefend" => "24",
    "MSSQLSERVER" => "25",
    'MSSQL$MSSQLSERVER2017' => "26",
    "MySQL56" => "27",
    "MySQL57" => "28",
    "MERADMS" => "29",
    "webengine" => "30",
    "windows" => "31",
    "nginx" => "32",
    "postgresql" => "33"
);

# ==========================================================================================
package LinuxDistribution;

#use 5.006000;
#use strict;
#use warnings;
#
#require Exporter;
#
#our @ISA = qw(Exporter);
#
#our @EXPORT_OK = qw( distribution_name distribution_version );
#
#our $VERSION = '0.23';

our $release_files_directory='/etc';
our $standard_release_file = 'lsb-release';

our %release_files = (
    'gentoo-release'        => 'gentoo',
    'fedora-release'        => 'fedora',
    'centos-release'        => 'centos',
    'enterprise-release'    => 'oracle enterprise linux',
    'turbolinux-release'    => 'turbolinux',
    'mandrake-release'      => 'mandrake',
    'mandrakelinux-release' => 'mandrakelinux',
    'debian_version'        => 'debian',
    'debian_release'        => 'debian',
    'SuSE-release'          => 'suse',
    'knoppix-version'       => 'knoppix',
    'yellowdog-release'     => 'yellowdog',
    'slackware-version'     => 'slackware',
    'slackware-release'     => 'slackware',
    'redflag-release'       => 'redflag',
    'redhat-release'        => 'redhat',
    'redhat_version'        => 'redhat',
    'conectiva-release'     => 'conectiva',
    'immunix-release'       => 'immunix',
    'tinysofa-release'      => 'tinysofa',
    'trustix-release'       => 'trustix',
    'adamantix_version'     => 'adamantix',
    'yoper-release'         => 'yoper',
    'arch-release'          => 'arch',
    'libranet_version'      => 'libranet',
    'va-release'            => 'va-linux',
    'pardus-release'        => 'pardus',
    'system-release'        => 'amazon',
    'CloudLinux-release'    => 'CloudLinux',
    'cloudlinux-release'    => 'cloudlinux-release',
    'almalinux-release'    => 'almalinux-release'
);

our %version_match = (
    'gentoo'                => 'Gentoo Base System release (.*)',
    'debian'                => '(.+)',
    'suse'                  => 'VERSION = (.*)',
    'fedora'                => 'Fedora(?: Core)? release (\d+) \(',
    'redflag'               => 'Red Flag (?:Desktop|Linux) (?:release |\()(.*?)(?: \(.+)?\)',
    'redhat'                => 'Red Hat(?: Enterprise)? Linux(?: Server)? release (.*) \(',
    'oracle enterprise linux' => 'Enterprise Linux Server release (.+) \(',
    'slackware'             => '^Slackware (.+)$',
    'pardus'                => '^Pardus (.+)$',
    'centos'                => '^CentOS(?: Linux)? release (.+) \(',
    'scientific'            => '^Scientific Linux release (.+) \(',
    'amazon'                => 'Amazon Linux AMI release (.+)$',
    'CloudLinux'            => 'CloudLinux Server release (\S+)',
    'cloudlinux-release'    => 'CloudLinux release (\S+)',
	'cloudlinux-release1'    => 'cloudlinux-release (\S+)',
    'almalinux-release'    => '^Alma(?:Linux)? release ([0-9]*[|\.[0-9]*]?)',
);


if ($^O ne 'linux') {
#   require Carp;
#   Carp::croak('you are trying to use a linux specific module on a different OS');
}

sub new {
    my %self = (
        'DISTRIB_ID'          => '',
        'DISTRIB_RELEASE'     => '',
        'DISTRIB_CODENAME'    => '',
        'DISTRIB_DESCRIPTION' => '',
        'release_file'        => '',
        'pattern'             => ''
    );
    
    return bless \%self;
}

sub distribution_name {
    my $self = shift || new();
    my $distro;
    if ($distro = $self->_get_lsb_info()){
        return $distro if ($distro);
    }

    foreach (qw(enterprise-release fedora-release CloudLinux-release almalinux-release)) {
        if (-f "$release_files_directory/$_" && !-l "$release_files_directory/$_"){
            if (-f "$release_files_directory/$_" && !-l "$release_files_directory/$_"){
                $self->{'DISTRIB_ID'} = $release_files{$_};
                $self->{'release_file'} = $_;
                #print "===============> \$self->{'DISTRIB_ID'}=$self->{'DISTRIB_ID'}";
                #print "===============> \$self->{'release_file'}=$self->{'release_file'}";
                return $self->{'DISTRIB_ID'};
            }
        }
    }

    foreach (keys %release_files) {
        if (-f "$release_files_directory/$_" && !-l "$release_files_directory/$_"){
            if (-f "$release_files_directory/$_" && !-l "$release_files_directory/$_"){
                if ( $release_files{$_} eq 'redhat' ) {
                    foreach my $rhel_deriv ('centos','scientific',) {
                        $self->{'pattern'} = $version_match{$rhel_deriv};
                        $self->{'release_file'}='redhat-release';
                        if ( $self->_get_file_info() ) {
                            $self->{'DISTRIB_ID'} = $rhel_deriv;
                            $self->{'release_file'} = $_;
                            return $self->{'DISTRIB_ID'};
                        }
                    }
                    $self->{'pattern'}='';
                }
                $self->{'release_file'} = $_;
                $self->{'DISTRIB_ID'} = $release_files{$_};
                #print "===============> \$self->{'DISTRIB_ID'}=$self->{'DISTRIB_ID'}";
                return $self->{'DISTRIB_ID'};
            }
        }
    }
    undef 
}

sub distribution_version {
    my $self = shift || new();
    my $release;
    return $release if ($release = $self->_get_lsb_info('DISTRIB_RELEASE'));
    if (! $self->{'DISTRIB_ID'}){
         $self->distribution_name() or die 'No version because no distro.';
    }
    $self->{'pattern'} = $version_match{$self->{'DISTRIB_ID'}};
    $release = $self->_get_file_info();
    $self->{'DISTRIB_RELEASE'} = $release;
    return $release;
}

sub _get_lsb_info {
    my $self = shift;
    my $field = shift || 'DISTRIB_ID';
    my $tmp = $self->{'release_file'};
    if ( -r "$release_files_directory/" . $standard_release_file ) {
        $self->{'release_file'} = $standard_release_file;
        $self->{'pattern'} = $field . '=["]?([^"]+)["]?';
        my $info = $self->_get_file_info();
        if ($info){
            $self->{$field} = $info;
            return $info
        }
    } 
    $self->{'release_file'} = $tmp;
    $self->{'pattern'} = '';
    undef;
}

sub _get_file_info {
    my $self = shift;
    open my $fh, '<', "$release_files_directory/" . $self->{'release_file'} or die 'Cannot open file: '.$release_files_directory.'/' . $self->{'release_file'};
    my $info = '';
    local $_;
    while (<$fh>){
        chomp $_;
        ($info) = $_ =~ m/$self->{'pattern'}/;
        return "\L$info" if $info;
    }
    undef;
}
# =================================================================================================================
#print "$^O\n";
# use LinuxDistribution qw(distribution_name distribution_version);
my $linux = LinuxDistribution->new();

# ========== main process =======================
print "\n############################\n";
if ($^O eq 'MSWin32') {
  print "===============> windows\n";
  windows_detect();
  convent_format();
} elsif ($linux) {
    my $distro = $linux->distribution_name();
    print "===> Distribution name : $distro\n";
    my $version = $linux->distribution_version();
    print "===> Distribution version : $version\n";
    print "OS Info : $distro $version\n";
    if ($distro =~ /almalinux/i) {
    	centos7_detect();
        convent_format();
    }
    elsif ($distro =~ /centos/i || $distro =~ /cloudlinux/i) {
        print "===============> centos or cloudlinux\n";
        if ($version =~ /^8\./i || $version =~ /^7\./i || $version =~ /^9\./i) {
            print "===============> centos7 or centos8 or centos9\n";
            centos7_detect();
            convent_format();
        } elsif ($version =~ /^6\./i || $version =~ /^5\./i) {
            print "===============> centos5\n";
            centos6_detect();
            convent_format();
        } else {
            print "Can't found version.";
        }
    } elsif ($distro =~ /ubuntu/i) {
     ubuntu_detect();
     convent_format();
    } elsif ($distro =~ /debian/i) {
     ubuntu_detect();
     convent_format();
    } else {
        print "===============> Not support\n";
    }
} else {
    print "OS Info : $^O unsupport\n";
    #exit''
}
print "\n############################\n";

# =========== function ==================================
sub windows_detect {
  # print "===============> windows detect \n";
  # print "Not have command for windows, now.";
  # system("'windows' >> service_run.txt");
  # system("'' >>  service_all.txt"); 
  # system("'' >> service_on.txt");
  # system("'windows' >> service_on.txt");
  
  my $file_service_on = 'service_on.txt';
  open(my $FSO, '>', $file_service_on) or die $!;
  print $FSO "windows\n";
  
  my $file_service_run = 'service_run.txt';
  open(my $FSR, '>', $file_service_run) or die $!;
  #print $FSR "$SERVICE{windows}\n";
  print $FSR "windows\n";
  
  eval { require Win32::Service; };
  Win32::Service::GetServices("", \%services);
  while ( my ($k,$v) = each %services ) {
    # print "$k\t$v\n";
    # print "GetServices=============>$k : $v\n";
    # print "=================================================\n";
    # print "$v\t\t : $k\n";
    if(exists($SERVICE{$v})) {
      print "$v\t\t : $k\n";
      print $FSO "$v\n";
      print $FSR "$v\n";
      #print $FSR "$SERVICE{$v}\n";
    }
    #system("echo '$v'> service_all.txt"); 
    #my %status;
    #Win32::Service::GetStatus("", $v, \%status);
    
    #while ( my ($k1,$v1) = each %status ) {
    #    # print "\t$k\t$v\n";
    #    if ($v1) {
    #      print "GetStatus=============>$k1 $v1\n";
    #    }
    #}
  }
  close($FSO);
  close($FSR);
}

sub centos7_detect { 
    print "===============> centos7 detect \n";
    system("cat /dev/null > service_run.txt");
    system("cat /dev/null >    service_all.txt"); 
    system("cat /dev/null >    service_on.txt"); 
    system("uname >> service_run.txt"); 
    system("systemctl list-units --type=service --state=active >> service_all.txt"); 
    system("grep -P \"loaded active\" service_all.txt > service_on.txt"); 
    system("cut -d '.' -f 1 service_on.txt >> service_run.txt"); 
}

sub centos6_detect { 
    print "===============> centos5 centos6 detect \n";
    system("cat /dev/null > service_run.txt");
    system("cat /dev/null > service_all.txt");
    system("cat /dev/null > service_on.txt");
    system("uname >> service_run.txt");
    system("chkconfig --list >> service_all.txt");
    system("grep -P \"(3:on)\" service_all.txt > service_on.txt");
    system("cut -f 1 service_on.txt >> service_run.txt");
}

sub ubuntu_detect {
	print "===============> ubuntu detect \n";
	# print "Not have command for ubuntu, now.";
  system("cat /dev/null >service_run.txt"); 
  system("cat /dev/null >service_on.txt"); 
  system("uname >> service_run.txt"); 
  system("service --status-all |grep '+' > service_on.txt "); 
  system("cut -d ' ' -f 6 service_on.txt >> service_run.txt"); 
}

sub convent_format {
    print "===============> convent format\n";
    my $filename = 'service_run.txt';
    my $txt = '';
    my $origRow = '';
    if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
        while (my $row = <$fh>) {
            chomp $row;
            $origRow = $row;
            $row =~ s/^\s+|\s+$//g;
            if(exists($SERVICE{$row})) {
                print "$origRow= $SERVICE{$row}\n";
                if ($txt eq '') {
                    $txt .= $SERVICE{$row};
                } else {
                    $txt .= ",$SERVICE{$row}";
                }
            }
        }
        if ($txt ne '') {
            open(my $fh, '>', 'service_meta.txt');
            print $fh $txt;
            close $fh;
        }
    } else {
        warn "Could not open file '$filename' $!\n";
        print "Please check file : '$filename'\n"
    }
    # print "===============> convent format done.\n";
}
