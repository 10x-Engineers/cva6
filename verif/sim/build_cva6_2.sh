#!/bash/bash
make clean_all
cd ../../
make clean
source verif/sim/setup-env.sh
export DV_SIMULATORS=veri-testharness
export TRACE_FAST=0
cd ./verif/sim
python3 cva6.py   --target cv64a6_imafdc_sv39_hpdcache  --iss=$DV_SIMULATORS   --iss_yaml=cva6.yaml   --elf_tests /work/gull/iopmp_baremetal/bin/iopmp_reg_rw.o   --linker=/work/gull/BareMetal_IOPMP_Tests/link.ld --iss_timeout 1000   --gcc_opts="-static -mcmodel=medany -nostdlib -fvisibility=hidden -nostartfiles -g \
  ../tests/custom/common/syscalls.c \
  ../tests/custom/common/crt.S \
 ../tests/custom/coremark/uart.c\
  -lgcc \
  -I../tests/custom/env -I../tests/custom/common"
