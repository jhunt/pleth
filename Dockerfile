FROM perl:5.32
RUN cpan -T Plack Carton

WORKDIR /app
COPY cpanfile .
COPY cpanfile.snapshot .
RUN ls -l
RUN carton install

CMD ["carton", "exec", "plackup", "bin/app.psgi"]
COPY . .
