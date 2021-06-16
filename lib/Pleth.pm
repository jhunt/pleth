package Pleth;
use Dancer2;

use Pleth::Data;

our $VERSION = '0.20210615.0';

set serializer => 'JSON';

local $SIG{INT}  = sub { exit 1; };
local $SIG{TERM} = sub { exit 1; };

my $dat;
sub dat {
	return $dat ||= Pleth::Data->new;
}

get '/v1/next/:n' => sub {
	status 200;
	return {
		total => dat->total_obs,
		seen  => dat->scanned_obs,
		obs => [dat->random_unscanned_obs(route_parameters->get('n'))],
	};
};

post '/v1/scan' => sub {
	dat->scan;
	status 200;
	return {
		total => dat->total_obs,
		seen  => dat->scanned_obs,
	};
};

get '/v1/obs' => sub {
	status 200;
	return [dat->obs];
};

post '/v1/ob/:id' => sub {
	dat->update(route_parameters->get('id'), request->body_data);
	status 204;
};

del '/v1/ob/:id' => sub {
	dat->archive(route_parameters->get('id'));
	status 204;
};

true;
