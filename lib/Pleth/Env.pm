package Pleth::Env;

sub redis {
	return $ENV{PLETH_REDIS} || '127.0.0.1:6379';
}

sub root {
	return $ENV{PLETH_ROOT} || 'data';
}

1;
