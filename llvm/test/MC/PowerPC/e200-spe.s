# RUN: llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z3 -show-encoding %s | FileCheck %s
# RUN: llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z4 -show-encoding %s | FileCheck %s
# RUN: llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z6 -show-encoding %s | FileCheck %s
# RUN: llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z7 -show-encoding %s | FileCheck %s

# CHECK: efsadd 3, 4, 5
# CHECK-SAME: encoding: [0x10,0x64,0x2a,0xc0]
efsadd 3, 4, 5
# CHECK: evaddw 3, 4, 5
# CHECK-SAME: encoding: [0x10,0x64,0x2a,0x00]
evaddw 3, 4, 5
# CHECK: evldd 3, 8(4)
evldd 3, 8(4)
