export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:\
../libclix/build/darwin:../libpal/build/darwin:\
../libclix/3rd/gfc/build/darwin:\
./3rd/argparse-1.1.0/build/darwin

export DYLD_LIBRARY_PATH=/export/local/works/doublegsoft.me/myhotkey/03.Development/libclix/build/darwin:\
/export/local/works/doublegsoft.me/myhotkey/03.Development/libpal/build/darwin:\
/export/local/works/doublegsoft.me/myhotkey/03.Development/libclix/3rd/gfc-0.1.2/build/darwin:\
/export/local/works/doublegsoft.me/myhotkey/03.Development/paws-cli/3rd/argparse-1.1.0/build/darwin

build/darwin/paws \
-p data/kimi/paws.pal \
-w data/kimi