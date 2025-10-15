#!/bash/bash
python3 cva6.py   --target cv64a6_imafdc_sv39_hpdcache  --iss=$DV_SIMULATORS   --iss_yaml=cva6.yaml   --c_tests ../tests/custom/hello_world/hello_world.c   --linker=../../config/gen_from_riscv_config/linker/link.ld   --gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g \
  ../tests/custom/common/syscalls.c \
  ../tests/custom/common/crt.S \
 ../tests/custom/coremark/uart.c\
  -lgcc \
  -I../tests/custom/env -I../tests/custom/common"
