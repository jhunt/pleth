requires 'Image::ExifTool' => 0;
requires 'YAML' => 0;
requires 'Digest::SHA1' => 0;
requires 'Redis' => 0;
requires 'JSON' => 0;

requires "Dancer2" => "0.300004";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
