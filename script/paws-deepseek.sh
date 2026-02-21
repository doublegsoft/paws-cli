export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:\
../libclix/build/darwin:../libpal/build/darwin:\
../libclix/3rd/gfc/build/darwin:\
./3rd/argparse-1.1.0/build/darwin

build/darwin/paws \
-p data/deepseek/paws.pal \
-w data/deepseek