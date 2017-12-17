#!/usr/bin/perl
package bdb2mongodb;
=pod
Created by Hajime Kuirta
Purpose: Convert BerkeleyDB (BDB) files into MongoDB's table
=cut
use BDB::Wrapper;
use Data::Dumper;
use MongoDB;

sub new(){
    my $self = {};
    return bless($self);
}

sub run(){
    my $self = shift;
    $self->init_vars();
    $self->convert();
    if($self->{'debug'}){
        $self->confirm();
    }
    $self->report();
}

sub usage(){
    my $self = shift;
    print <<EOF;
# Usage
perl bdb2mongodb.pl --file=/../../../.../(...).bdb --database=...

## Actual example
perl bdb2mongodb/bdb2mongodb.pl --database=sakuhindb --file=/www/data/bdb/anime/works/youtube_name.bdb --key=url --drop

## Parameters
--database=... Mandatory

--debug Optional: More info will be shown in the process

--drop or --initialize Optional: Drop the collection if exist

--file=... Mandatory: value for the input of BerkeleyDB

--key=... Optional: If the value is blank, "bdbKey" will be used key name of Berkeley DB's key's name. Index will be added to "bdbKey" automatically

--mongoport=... Optional: If the value is blank, 27017 will be used.

--mongoserver=... Optional: If the value is blank, localhost will be used.

--table= or --collection=... Optional: If the value is blank, the name of bdb file will be used for table name

--key=... Optional: If the value is blank, "bdbValue" will be used key name of Berkeley DB's value's name
EOF
    exit;
}

sub init_vars(){
    my $self = shift;
    $self->{'database'} = 'general';
    $self->{'debug'} = 0;
    $self->{'file'} = '';
    $self->{'table'} = '';
    $self->{'mongoserver'} = 'localhost';
    $self->{'mongoport'} = '27017';
    $self->{'covnerted'} = 0;
    $self->{'key'} = 'bdbKey';
    $self->{'val'} = 'bdbVal';
    $self->{'drop'} = 0;

    foreach my $ARGV (@ARGV){
        if($ARGV=~ m!^\-!){
            if($ARGV=~ m!^--debug!){
                $self->{'debug'}++;
            }
            elsif($ARGV=~ m!^--collection=(.*)!){
                $self->{'table'} = $1;
            }
            elsif($ARGV=~ m!^--database=(.*)!){
                $self->{'database'} = $1;
            }
            elsif($ARGV=~ m!^--drop!){
                $self->{'drop'}++;
            }
            elsif($ARGV=~ m!^--file=(.*)!){
                $self->{'file'} = $1;
            }
            elsif($ARGV=~ m!^--initialize!){
                $self->{'drop'}++;
            }
            elsif($ARGV=~ m!^--key=(.*)!){
                $self->{'key'} = $1;
            }
            elsif($ARGV=~ m!^--mongoport=(.*)!){
                $self->{'mongoport'} = $1;
            }
            elsif($ARGV=~ m!^--mongoserver=(.*)!){
                $self->{'mongoserver'} = $1;
            }
            elsif($ARGV=~ m!^--table=(.*)!){
                $self->{'table'} = $1;
            }
            elsif($ARGV=~ m!^--val=(.*)!){
                $self->{'val'} = $1;
            }
            else{
                die("Unsupported parameter: ".$ARGV);
            }
        }
    }
    unless($self->{'file'}){
        die("Please specify file");
    }

    unless($self->{'database'}){
        die("Please specify database");
    }

    unless($self->{'key'}){
        die("Please specify key");
    }

    unless($self->{'val'}){
        die("Please specify val");
    }

    unless($self->{'table'}){
        if($self->{'file'}=~ m!/([^/]+)\.bdb$!){
            $self->{'table'} = $1;
        }
        elsif($self->{'file'}=~ m!([^/]+)\.bdb$!){
            $self->{'table'} = $1;
        }
        unless($self->{'table'}){
            die("Table is not specified");
        }
    }

    unless($self->{'table'}){
        die("Please specify table");
    }
    
    $self->{'murl'} = 'mongodb://'.$self->{'mongoserver'}.':'.$self->{'mongoport'};
}

sub convert(){
    my $self = shift;
    my $bdbw = new BDB::Wrapper;
    if(my $bdbh = $bdbw->create_read_dbh($self->{'file'})) {
        unless($self->{'mongoClient'}){
            $self->{'mongoClient'} = MongoDB->connect($self->{'murl'});
        }
        my $mdbh = $self->{'mongoClient'}->get_database($self->{'database'});
        my $mc = $mdbh->get_collection($self->{'table'});
        if($self->{'drop'}) {
            $mc->drop;
        }
        $mc->ensure_index({$self->{'key'} => 1}, {"unique" => 1});

        if(my $cursor=$bdbh->db_cursor()){
            my $key = '';
            my $val = '';
            while($cursor->c_get($key, $val, DB_NEXT)==0){
                if($self->{'debug'}){
                    print $key."\t".$val."\n";
                }
                $mc->update_one({$self->{'key'}=>$key}, {'$set' => {$self->{'key'}=>$key, $self->{'val'}=>$val}}, {'upsert'=>1});
                $self->{'covnerted'}++;
            }
            $cursor->c_close();
        }
        $bdbh->db_close();
    }
}

sub confirm(){
    my $self = shift;
    unless($self->{'mongoClient'}){
        $self->{'mongoClient'} = MongoDB->connect($self->{'murl'});
    }
    my $cursor = $self->{'mongoClient'}->get_database($self->{'database'})->get_collection($self->{'table'})->find();
    while (my $object = $cursor->next) {
        print Data::Dumper::Dumper $object;
    }
}

sub report(){
    my $self = shift;
    print 'Converted: '.$self->{'covnerted'};
}

my $pro = new bdb2mongodb;
$pro->run();
