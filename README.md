# 5-Stage-Pipeline-CPU

This repository contains an implementation of a 5-stage pipelined CPU written in Verilog.
The design follows the classic pipeline stages:

**Instruction Fetch (IF)

Instruction Decode (ID)

Execute (EX)

Memory Access (MEM)

Write Back (WB)**

The project is divided into multiple lab files (Lab1.v, Lab2.v, etc.), each corresponding to different stages or milestones of the CPU implementation. The cpu.v file contains the CPU and its internal modules (like yALU and yMux)

# Requirements

To run this project, you must have the following installed:

Icarus Verilog (iverilog)

A command-line interface (Command Prompt, Terminal, etc.)

# Installing Icarus Verilog

Linux: 
Run the following command in the command line

sudo apt install iverilog
  
Windows: 
Download and install from the Icarus Verilog website


# How to Compile and Run

Open a command prompt or terminal. Navigate to the directory containing the Verilog files. Compile the CPU and the desired lab file using iverilog. Run the simulation using vvp.

Example using Lab1.v: 

iverilog Lab1.v cpu.v

vvp a.out

