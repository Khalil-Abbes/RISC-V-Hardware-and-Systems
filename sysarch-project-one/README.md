# Hardware Design with Chisel

## Project Context
This repository contains my student implementations for a hardware design project using the Chisel hardware description language.

**Provided by the University:**
A skeleton Chisel project with a nearly complete RISC-V RV32I processor implementation, base test infrastructure (including sanitizer tests and a program loader for assembly programs), module interfaces (Decoder, Control Unit, ALU, Branch Unit), Chisel enums for instruction types and control signals, and a `.vscode` configuration for development with VS Code + Metals.

**Implemented by Me:**
The arithmetic circuits and processor extensions described below, built on top of the provided skeleton.

## Tech Stack
* Scala, Chisel (Hardware Description Language)
* Java, sbt (Simple Build Tool)
* VS Code with Metals language server

## My Contributions

### Arithmetic Circuits (`src/main/scala/arithmetic`)
* **Division Circuit:** Designed a sequential circuit implementing integer division of two n-bit unsigned numbers using the long division algorithm, with `quotient`, `remainder`, and `done` output signals.
* **Faster Division (Bonus):** Extended the division circuit to terminate early under identifiable conditions, reducing the number of cycles needed.
* **Vector Unit:** Implemented a `ParallelUnit` generator that applies a scalar operation to a vector of elements in parallel using `arraySize` many computational units, completing in `vectorSize/arraySize` cycles.

### RISC-V Processor Extensions (`src/main/scala/RISC-V`)
* **Function Calls (`jal`, `jalr`):** Extended the decoder, control unit, and RV32I execution unit to support unconditional jump instructions for function calls.
* **Load Instructions (`lw`, `lb`, `lbu`, `lh`, `lhu`):** Implemented all RV32I load instructions by adapting the processor to handle memory requests with cycle-accurate stall signaling.
* **Multiplication & Division Instructions (M-Extension):** Implemented `mul`, `mulh`, `mulhsu`, `mulhu`, `div`, `divu`, `rem`, `remu` in dedicated `MultiplicationUnit` and `DivisionUnit` execution units.
* **Bonus — Hardware Division Integration:** Wired the custom sequential division circuit from Part 1 into the processor pipeline, using stall signals to wait for multi-cycle division to complete.

*Key files containing my implementations: `src/main/scala/arithmetic/`, `src/main/scala/RISC-V/`.*
