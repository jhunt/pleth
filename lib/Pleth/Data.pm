package Pleth::Data;
use strict;
use warnings;

use Redis;
use JSON;
use Digest::SHA;
use Image::ExifTool qw/:Public/;
use File::Find;

use Pleth::Env;

sub new {
	my ($class) = @_;

	return bless({
		rd => Redis->new(
			server => Pleth::Env->redis,
		),
	}, $class);
}

sub total_obs {
	my ($self) = @_;
	return $self->{rd}->scard('scanned') + $self->{rd}->scard('unscanned');
}

sub scanned_obs {
	my ($self) = @_;
	return $self->{rd}->scard('scanned');
}

sub random_unscanned_obs {
	my ($self, $n) = @_;
	return map { $self->get($_) }
		$self->{rd}->srandmember('unscanned', $n);
}

sub obs {
	my ($self) = @_;
	return map { $self->get($_) }
		$self->{rd}->smembers('scanned');
}

sub get {
	my ($self, $id) = @_;
	return decode_json($self->{rd}->get("ob:$id") || 'null');
}

sub scan {
	my ($self) = @_;
	find({
		no_chdir => 1,
		wanted => sub {
			return unless -f $_;
			$self->add($_);
		},
	}, Pleth::Env->root());
	# NOTE: ^^ will get slower and slower, as we scan over the top of existing data
}

sub add {
	my ($self, $file) = @_;

	my $sha = Digest::SHA->new('sha256');
	$sha->addfile($file);
	my $id = $sha->hexdigest;

	return if $self->{rd}->get("ob:$id");
	$self->{rd}->set("ob:$id", encode_json({
		file   => $file,
		sha256 => $id,
		fs     => fsinfo($file),
		exif   => exifinfo($file),
	}));
	return $self->set_in($id, 'unscanned');
	return $id;
}

sub archive {
	my ($self, $id) = @_;
	return $self->set_in($id, 'archived');
}

sub update {
	my ($self, $id, $params) = @_;
	my $ob = $self->get($id)
		or return;

	use Data::Dumper;
	print STDERR Dumper($params);
	map { $ob->{$_} = $params->{$_} } qw/tags metadata/;
	$self->{rd}->set("ob:$id", encode_json($ob));
	return $self->set_in($id, 'scanned');
}

sub set_in {
	my ($self, $id, $in) = @_;
	$self->{rd}->sadd($in, $id);
	map { $self->{rd}->srem($_, $id) } grep { $_ ne $in } qw/scanned unscanned archived/;
	return $self;
}

sub fsinfo {
	my ($file) = @_;
	my @st = stat($file);

	return {
		inode => "$st[0]:$st[1]",
		size  => $st[7],
		atime => $st[8],
		mtime => $st[9],
		ctime => $st[10],
	};
}

sub exifinfo {
	my ($file) = @_;
	my $exif = ImageInfo($file) || {};
	for my $k (sort keys %$exif) {
		delete($exif->{$k}) if ref($exif->{$k}) eq 'SCALAR';
	}
	return $exif;
}

1;
