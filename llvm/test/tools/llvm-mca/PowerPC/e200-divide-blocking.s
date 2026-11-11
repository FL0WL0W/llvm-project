# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z3 -iterations=1 %s | FileCheck %s --check-prefix=Z3
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z4 -iterations=1 %s | FileCheck %s --check-prefix=Z4
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z6 -iterations=1 %s | FileCheck %s --check-prefix=Z6
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z7 -iterations=1 %s | FileCheck %s --check-prefix=Z7

# An independent add must wait for the blocking divide even on dual-issue cores.
# Each run includes the divide latency plus dispatch/completion of the add.
# Z3: Total Cycles: 18
# Z4: Total Cycles: 16
# Z6: Total Cycles: 18
# Z7: Total Cycles: 17
divw 3, 4, 5
add 6, 7, 8
