======================
PowerPC e200 Book E CPUs
======================

This fork is based on upstream LLVM ``main``. Clang, LLVM code generation, the integrated assembler, and llvm-mca recognize ``e200z3``,
``e200z4``, ``e200z6``, and ``e200z7``. These names select the historical
Book E implementations with 64-bit SPE general-purpose registers. They do
not describe every later core sold under the same family name.

Usage
=====

For example, compile a freestanding translation unit for the e200z6 with::

  clang --target=powerpc-unknown-eabi -mcpu=e200z6 -O2 -ffreestanding -c app.c

Use ``-mtune=e200z3``, ``-mtune=e200z4``, ``-mtune=e200z6``, or
``-mtune=e200z7`` to select scheduling independently of the instruction set.
Use ``-msoft-float`` when software floating point is required.

The CPU defaults enable Book E, integer select, time-base access, msync,
and SPE with single-precision embedded floating point. They define
``__SPE__`` and use the existing LLVM SPE register and calling-convention
support. Single-precision arithmetic uses ``efs*`` instructions. Double
arithmetic and conversions requiring a double-precision FPU use software
helpers, such as ``__adddf3`` and ``__extendsfdf2``. A compatible runtime
must supply those helpers when linking. Long double has the existing SPE
64-bit representation. Classic FPR, AltiVec, VSX, and 64-bit PowerPC
instructions are not enabled by these CPU definitions.
Startup and context-switch code remain responsible for enabling MSR[SPE]
and preserving the SPE architectural state.

The ``spe-single`` target feature restricts the existing SPE support to
implementations without the double-precision EFD APU. ``efpu2`` implies
this restriction as well. The integrated assembler rejects EFD instructions
and ``efscfd`` for these CPUs. The generic ``e500`` CPU retains its existing
double-precision SPE behavior.

Scheduling
==========

The models describe in-order execution, functional-unit contention, operand
latencies, and pipelined throughput. llvm-mca can inspect assembly, for example::

  llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z6 -instruction-info app.s

=====================  ======  =====  ========  ========  ==============  =============
CPU                    Stages  Issue  Load use  Multiply  Single FP       FP divide
=====================  ======  =====  ========  ========  ==============  =============
e200z3                 4       1      1         1         1               12
e200z4 (e200z446)       5       2      2         2         2               13
e200z6                 7       1      3         3         3               12
e200z7 (e200z760)       10      2      3         3         4               9
=====================  ======  =====  ========  ========  ==============  =============

Latencies are cycles from execution to a forwarded result, rather than
total fetch-to-writeback time. Ordinary multiplies and FP operations have
a one-cycle initiation interval. Scalar integer divides use conservative
worst-case latencies of 16, 14, 16, and 15 cycles respectively; SPE vector
integer divides use 32 cycles. Divides block dispatch of following
instructions. Dual-issue models share one load/store unit and one branch
unit. Scalar and vector multiply/FP resources encode the principal pairing
restrictions. Branch misprediction costs are 2, 3, 3, and 6 cycles respectively.

These are compiler scheduling models, not cycle-accurate simulators. They
assume cache hits or zero-wait-state memory, and omit memory-system stalls,
exception handling, and some operand-specific forwarding and serialization.
The models are marked incomplete: privileged/system instructions and
load/store multiple instructions require additional modelling. Record-form
multiply condition codes and load-to-address forwarding can have additional
delays. Existing LLVM SPE instruction selection is reused; this change does
not add a new SPE intrinsic API or general SPE SIMD auto-vectorization.
SPE accumulator bypasses and floating-point exception-state dependencies
are not modelled separately.

Excluded implementations
========================

VLE is outside the scope of this fork. The VLE-only e200z2 family is not
registered as a code-generation target. Many MPC57xx e200z4 and e200z7
variants also only execute VLE or replace SPE with LSP; the family CPU names
must not be used to compile code for those implementations. Consult the
part's reference manual before choosing a target. SPE2 and LSP extensions
are not implemented here.

References
==========

* Freescale e200z3 Power Architecture Core Reference Manual, Rev. 2,
  chapter 6; also `ST UM0434
  <https://www.st.com/resource/en/user_manual/cd00160310.pdf>`_.
* Freescale e200z4 Power Architecture Core Reference Manual, Rev. 0,
  chapters 4, 6, and 7; Book E core features are also documented in
  `ST RM0068 <https://www.stmicroelectronics.com/resource/en/reference_manual/cd00288665.pdf>`_.
* Freescale E200Z6_RM, Rev. 0, chapter 7; `NXP e200 core family
  <https://www.nxp.com/products/nxp-product-information/ip-block-licensing/e200-core-family-nxp-power-architecture-ip:E200-CORE-FAMILY>`_.
* Freescale e200z760n3 Power Architecture Core Reference Manual, Rev. 2,
  chapters 4 and 6.
* `NXP AN4802, MPC57xx e200zx Core Differences
  <https://www.nxp.com/docs/en/application-note/AN4802.pdf>`_, especially
  the Book E and signal-processing options in table 3.

Build and test
==============

A PowerPC-only build is sufficient::

  cmake -S llvm -B build-e200 -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=PowerPC \
    -DLLVM_DEFAULT_TARGET_TRIPLE=powerpc-unknown-eabi \
    -DLLVM_ENABLE_ASSERTIONS=ON
  ninja -C build-e200 clang llc llvm-mc llvm-mca FileCheck count not
  build-e200/bin/llvm-lit clang/test/CodeGen/PowerPC/e200.c \
    clang/test/Preprocessor/e200.c llvm/test/MC/PowerPC/e200*.s \
    llvm/test/tools/llvm-mca/PowerPC/e200*.s
