//===-- PPCScheduleE200.td - e200 Scheduling Definitions ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Book E implementations: e200z3, e200z446, e200z6 and e200z760.
// Sources: e200z3RM Rev. 2, chapter 6; e200z4RM Rev. 0,
// chapters 4, 6 and 7; E200Z6_RM Rev. 0, chapter 7; e200z760n3RM Rev. 2,
// chapters 4 and 6. See docs/PowerPCE200.rst for scope and limitations.
//
// Latencies describe execution with operand forwarding and zero-wait-state
// memory/cache hits, not total fetch-to-writeback pipeline depth. Divides use
// worst-case timing and block dispatch. Ordinary multicycle operations pipeline
// with a one-cycle initiation interval.
//===----------------------------------------------------------------------===//

class E200Model<int Width, int Load, int Branch> : SchedMachineModel {
  let IssueWidth = Width;
  let MicroOpBufferSize = 0; // In-order issue and completion.
  let LoadLatency = Load;
  let MispredictPenalty = Branch;
  // System instructions and load/store multiple have implementation- and
  // operand-dependent timing; the model deliberately remains incomplete.
  let CompleteModel = 0;
}

def E200Z3Model : E200Model<1, 1, 2>;
def E200Z4Model : E200Model<2, 2, 3>;
def E200Z6Model : E200Model<1, 3, 3>;
def E200Z7Model : E200Model<2, 3, 6>;

multiclass E200Resources<SchedMachineModel Model, int Width, int LoadCycles,
                         int Multiply, int FP, int Divide, int FPDivide> {
  let SchedModel = Model in {
    // Every instruction needs a dispatch slot. Keeping the slots separate lets
    // blocking divides reserve both, including on dual-issue implementations.
    def Dispatch0 : ProcResource<1> { let BufferSize = 0; }
    def Dispatch1 : ProcResource<1> { let BufferSize = 0; }
    def Dispatch : ProcResGroup<!if(!eq(Width, 1),
                           [!cast<ProcResource>(NAME # "Dispatch0")],
                           [!cast<ProcResource>(NAME # "Dispatch0"),
                            !cast<ProcResource>(NAME # "Dispatch1")])>;
    def ALU : ProcResource<Width>;
    def LSU : ProcResource<1>;
    def BRU : ProcResource<1>;
    def MUL0 : ProcResource<1>;
    def MUL1 : ProcResource<1>;
    def MUL : ProcResGroup<[!cast<ProcResource>(NAME # "MUL0"),
                           !cast<ProcResource>(NAME # "MUL1")]>;
    def FPU0 : ProcResource<1>;
    def FPU1 : ProcResource<1>;
    def FPU : ProcResGroup<[!cast<ProcResource>(NAME # "FPU0"),
                           !cast<ProcResource>(NAME # "FPU1")]>;

    def Int : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                            !cast<ProcResource>(NAME # "ALU")]>;
    def Address : SchedWriteRes<[]> { let NumMicroOps = 0; }
    def Load : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                             !cast<ProcResource>(NAME # "LSU")]> {
      let Latency = LoadCycles;
    }
    def Store : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                              !cast<ProcResource>(NAME # "LSU")]> {
      let Latency = 0;
    }
    def Branch : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                               !cast<ProcResource>(NAME # "BRU")]>;
    def Mul : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                            !cast<ProcResGroup>(NAME # "MUL")]> {
      let Latency = Multiply;
    }
    def VecMul : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                               !cast<ProcResource>(NAME # "MUL0"),
                               !cast<ProcResource>(NAME # "MUL1")]> {
      let Latency = Multiply;
    }
    def Float : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                              !cast<ProcResGroup>(NAME # "FPU")]> {
      let Latency = FP;
    }
    def VecFloat : SchedWriteRes<[!cast<ProcResGroup>(NAME # "Dispatch"),
                                 !cast<ProcResource>(NAME # "FPU0"),
                                 !cast<ProcResource>(NAME # "FPU1")]> {
      let Latency = FP;
    }
    def Div : SchedWriteRes<[!cast<ProcResource>(NAME # "Dispatch0"),
                            !cast<ProcResource>(NAME # "Dispatch1")]> {
      let Latency = Divide;
      let ReleaseAtCycles = [Divide, Divide];
      let BeginGroup = 1;
      let EndGroup = 1;
    }
    def VecDiv : SchedWriteRes<[!cast<ProcResource>(NAME # "Dispatch0"),
                               !cast<ProcResource>(NAME # "Dispatch1")]> {
      let Latency = 32;
      let ReleaseAtCycles = [32, 32];
      let BeginGroup = 1;
      let EndGroup = 1;
    }
    def FloatDiv : SchedWriteRes<[!cast<ProcResource>(NAME # "Dispatch0"),
                                 !cast<ProcResource>(NAME # "Dispatch1")]> {
      let Latency = FPDivide;
      let ReleaseAtCycles = [FPDivide, FPDivide];
      let BeginGroup = 1;
      let EndGroup = 1;
    }

    def : ItinRW<[!cast<SchedWrite>(NAME # "Int")],
                 [IIC_IntSimple, IIC_IntGeneral, IIC_IntCompare, IIC_IntISEL,
                  IIC_IntRotate, IIC_IntShift, IIC_BrCR, IIC_BrMCR, IIC_BrMCRX,
                  IIC_SprMFCR, IIC_SprMFCRF, IIC_SprMFSPR, IIC_SprMTSPR,
                  IIC_SprMFTB, IIC_SprMFMSR, IIC_VecGeneral, IIC_VecComplex,
                  IIC_VecPerm]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Mul")],
                 [IIC_IntMulHW, IIC_IntMulHWU, IIC_IntMulLI]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Div")], [IIC_IntDivW]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Load")],
                 [IIC_LdStLoad, IIC_LdStLHA, IIC_LdStLWARX]>;
    // Updated base registers are available from the address-generation stage.
    def : ItinRW<[!cast<SchedWrite>(NAME # "Load"),
                  !cast<SchedWrite>(NAME # "Address")],
                 [IIC_LdStLoadUpd, IIC_LdStLoadUpdX,
                  IIC_LdStLHAU, IIC_LdStLHAUX]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Store")],
                 [IIC_LdStStore, IIC_LdStSTWCX]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Address"),
                  !cast<SchedWrite>(NAME # "Store")],
                 [IIC_LdStSTU, IIC_LdStSTUX]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Branch")], [IIC_BrB]>;
    def : ItinRW<[!cast<SchedWrite>(NAME # "Float")],
                 [IIC_FPGeneral, IIC_FPSGeneral, IIC_FPAddSub, IIC_FPCompare]>;

    // SPE itinerary classes are shared by dissimilar operations. Override
    // individual opcodes so e.g. EFSADD and EVFSADD do not consume the same
    // resources, and EFSDIV is not mistaken for a double-precision divide.
    def : InstRW<[!cast<SchedWrite>(NAME # "FloatDiv")],
                  (instrs EFSDIV, EVFSDIV)>;
    def : InstRW<[!cast<SchedWrite>(NAME # "VecDiv")],
                  (instrs EVDIVWS, EVDIVWU)>;
    def : InstRW<[!cast<SchedWrite>(NAME # "VecMul")],
                  (instrs (instregex "^EVMH.*"), (instregex "^EVMW.*"))>;
    def : InstRW<[!cast<SchedWrite>(NAME # "VecFloat")],
                  (instrs (instregex "^EVFS(ABS|ADD|CF.*|CMP.*|CT.*|MUL|NABS|NEG|SUB|TST.*)$"))>;
  }
}

defm E200Z3 : E200Resources<E200Z3Model, 1, 1, 1, 1, 16, 12>;
defm E200Z4 : E200Resources<E200Z4Model, 2, 2, 2, 2, 14, 13>;
defm E200Z6 : E200Resources<E200Z6Model, 1, 3, 3, 3, 16, 12>;
defm E200Z7 : E200Resources<E200Z7Model, 2, 3, 3, 4, 15, 9>;
