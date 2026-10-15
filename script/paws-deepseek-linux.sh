export MYHOTKEY_03=/export/local/works/doublegsoft.me/myhotkey/03.Development
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MYHOTKEY_03/libclix/build/linux:$MYHOTKEY_03/libpal/build/linux:3rd/argparse-1.1.0/build/linux

build/linux/paws \
-p $MYHOTKEY_03/paws-cli/data/deepseek-linux/paws.pal \
-w $MYHOTKEY_03/paws-cli/data/deepseek-linux
