// REQUIRES: powerpc-registered-target
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z3 -O2 -S -o - %s | FileCheck %s
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z4 -O2 -S -o - %s | FileCheck %s
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z6 -O2 -S -o - %s | FileCheck %s
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z7 -O2 -S -o - %s | FileCheck %s
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z6 -O2 -mllvm -verify-machineinstrs -c -o %t.o %s
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z6 -msoft-float -O2 -S -o - %s | FileCheck %s --check-prefix=SOFT
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z6 -mtune=e200z7 -O2 -S -o - %s | FileCheck %s

// CHECK-LABEL: add_float:
// CHECK: efsadd
// SOFT-LABEL: add_float:
// SOFT: bl __addsf3
float add_float(float a, float b) { return a + b; }

// CHECK-LABEL: multiply_float:
// CHECK: efsmul
float multiply_float(float a, float b) { return a * b; }

// CHECK-LABEL: divide_float:
// CHECK: efsdiv
float divide_float(float a, float b) { return a / b; }

// CHECK-LABEL: add_double:
// CHECK-NOT: efdadd
// CHECK: bl __adddf3
double add_double(double a, double b) { return a + b; }

// CHECK-LABEL: extend_float:
// CHECK-NOT: efdcfs
// CHECK: bl __extendsfdf2
double extend_float(float a) { return a; }

// CHECK-LABEL: truncate_double:
// CHECK-NOT: efscfd
// CHECK: bl __truncdfsf2
float truncate_double(double a) { return a; }
