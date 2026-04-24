export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:../libclix/build/linux:../libpal/build/linux:3rd/argparse-1.1.0/build/linux

echo '' > data/deepseek-linux/ccbs.log

for file in "/home/christian/Pictures"/*; do
  [ -f "$file" ] || continue
  base="$(basename "$file")"
  name="${base%.*}"
  bill="${name:0:12}"
  bill_seq="$bill"1

  echo $bill >> data/deepseek-linux/ccbs.log
  build/linux/paws -p data/deepseek-linux/paws.pal -w data/deepseek-linux
  rm -f $file
done
