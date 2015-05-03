
#mkdir -p /media/tmpfs
#mount -t tmpfs -o size=20m tmpfs /media/tmpfs
#cp data/* /media/tmpfs/

bin/susan/susan_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path susan_c.json /media/tmpfs/input_large.pgm -c
bin/susan/susan_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path susan_e.json /media/tmpfs/input_large.pgm -e

bin/fft/fft_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path fft.json "4 4096"
bin/fft/fft_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path fft_i.json "4 8192 -i"

bin/rijndael/aes_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path aes_e.json /media/tmpfs/input_small.asc /media/tmpfs/output_small.enc e 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321
bin/rijndael/aes_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path aes_d.json /media/tmpfs/output_small.enc /media/tmpfs/output_small.dec d 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321

bin/qsort/smallQsort_O2.elf --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path qsort.json /media/tmpfs/input_small.dat

bin/patricia/patricia_O2.elf  --core 0 --pmu bp --modulePath bin/bpMod.ko --moduleArgs "action=PROFILING" --nTimes 30 --path patricia.json /media/tmpfs/small.udp
