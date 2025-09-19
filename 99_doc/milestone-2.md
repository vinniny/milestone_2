# Milestone 2 Criteria (Extracted)

Milestone 2 — EE3043 Computer Architecture
Design of a Single Cycle RISC-V Processor
Hai Cao
rev 1.1.0
Contents
1 Objectives 2
2 Overview 2
2.1 Processor Specification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
2.2 General Design Guidelines . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
2.2.1 Directory structure . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
3 Processor Components and Requirements 5
3.1 Arithmetic Logic Unit (ALU) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.1.1 Requirement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.1.2 Suggested specification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.2 Branch Comparison Unit (BRC) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.2.1 Requirement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.2.2 Suggested specification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.3 Regfile . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.3.1 Requirement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.3.2 Suggested specification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.4 I/O System and Memory . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.4.1 Memory Mapping . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.4.2 Requirement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
3.4.3 Suggested specification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
3.4.4 Special considerations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
3.5 Additional Components . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
4 Modified Processor 9
5 Verification 9
6 I/O System Conventions 9
1
Milestone 2 — EE3043 Computer Architecture
7 Applications 11
8 Rubric 11
8.1 Report . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12
Abstract
This document provides an overview of the tasks, expectations, and requirements for
the second milestone in the Computer Architecture course. It details the specific compo-
nents and specifications students must follow to successfully design a single-cycle RV32I
processor. For any errors found or suggestions for enhancement, contact the TA via email
at cxhai.sdh221@hcmut.edu.vn using the subject line “ [CA203 FEEDBACK] ”.
1 Objectives
•Review understanding of SystemVerilog
•Review understanding of RV32I instructions
•Design a single-cycle RV32I processor
2 Overview
In this milestone, students are tasked with designing a single-cycle RV32I processor, as dis-
cussed in lectures. To enable communication between your custom processor (soft-core) and
external peripherals, some modifications to the standard processor design are necessary. The
designmustadheretothespecificationsoutlinedbelowandwillbetestedagainstbothstudent-
created testbenches and a comprehensive testbench provided by the TA. Adherence to the
suggested specifications, while not mandatory, is strongly recommended.
2
Milestone 2 — EE3043 Computer ArchitectureI$pc instrPCpc_next
+4pc_four
Regfile
ImmGenBRCoperand_a
operand_b
LSUalu_data
ld_datawb_data
ControlUnitpc_sel rd_wren br_unbr_less br_equal opa_sel opb_sel alu_op mem_wren wb_selrs1_addr
rs2_addr
rd_addr
rd_wrenrs1_data
rs2_datard_datapc
pc_four
rs2_data I/O
o_pc_debugo_io_ledr
o_io_ledg
o_io_lcd
i_io_swo_io_hex0..7
o_insn_vldi_io_btn
insn_vld
Figure 1: Single Cycle Processor
3
Milestone 2 — EE3043 Computer Architecture
2.1 Processor Specification
•Top-level module: singlecycle.sv
•I/O ports:
Signal name Width Direction Description
i_clk 1 input Global clock, active on the rising edge.
i_rst_n 1 input Global low active reset.
o_pc_debug 32 output Debug program counter.
o_insn_vld 1 output Instruction valid.
o_io_ledr 32 output Output for driving red LEDs.
o_io_ledg 32 output Output for driving green LEDs.
o_io_hex0..7 7 output Output for driving 7-segment LED displays.
o_io_lcd 32 output Output for driving the LCD register.
i_io_sw 32 input Input for switches.
i_io_btn 4 input Input for buttons.
2.2 General Design Guidelines
2.2.1 Directory structure
Theprojectshouldmaintainawell-organizeddirectoryhierarchyforefficientmanagementand
submission:
1.
2|-- 00_src # Verilog source files
3|-- 01_bench # Testbench files
4|-- 02_test # Testing files
5| |-- asm # Assembly test code
6| `-- dump # Binary/hex dump files
7|-- 10_sim # Simulation files
8|-- 20_syn # Synthesis files
9| `-- quartus
10| |-- run # Makefile for synthesis
11| `-- src # Source files specific to synthesis
12`-- 99_doc # Documentation files
4
Milestone 2 — EE3043 Computer Architecture
3 Processor Components and Requirements
3.1 Arithmetic Logic Unit (ALU)
3.1.1 Requirement
TheALUmustbecapableofexecutingavarietyofarithmeticandlogicaloperationsasdefined
by the RV32I instruction set.
alu_op Description (R-type) Description (I-type)
ADD 𝑟𝑑←𝑟𝑠1+𝑟𝑠2 𝑟𝑑←𝑟𝑠1+𝑖𝑚𝑚
SUB 𝑟𝑑←𝑟𝑠1−𝑟𝑠2 𝑛/𝑎
SLT 𝑟𝑑←( 𝑟𝑠1<𝑟𝑠2)? 1 : 0 𝑟𝑑←( 𝑟𝑠1<𝑖𝑚𝑚)? 1 : 0
SLTU 𝑟𝑑←( 𝑟𝑠1<𝑟𝑠2)? 1 : 0 𝑟𝑑←( 𝑟𝑠1<𝑖𝑚𝑚)? 1 : 0
XOR 𝑟𝑑←𝑟𝑠1⊕𝑟𝑠2 𝑟𝑑←𝑟𝑠1⊕𝑖𝑚𝑚
OR 𝑟𝑑←𝑟𝑠1∨𝑟𝑠2 𝑟𝑑←𝑟𝑠1∨𝑖𝑚𝑚
AND 𝑟𝑑←𝑟𝑠1∧𝑟𝑠2 𝑟𝑑←𝑟𝑠1∧𝑖𝑚𝑚
SLL 𝑟𝑑←𝑟𝑠1≪𝑟𝑠2[4 : 0] 𝑟𝑑←𝑟𝑠1≪𝑖𝑚𝑚[4 : 0]
SRL 𝑟𝑑←𝑟𝑠1≫𝑟𝑠2[4 : 0] 𝑟𝑑←𝑟𝑠1≫𝑖𝑚𝑚[4 : 0]
SRA 𝑟𝑑←𝑟𝑠1≫𝑟𝑠2[4 : 0] 𝑟𝑑←𝑟𝑠1≫𝑖𝑚𝑚[4 : 0]
Note:Do not use built-in SystemVerilog operators for subtraction ( −), comparison ( <,>),
or shifting (≪,≫, and≫).
3.1.2 Suggested specification
•Module name: alu.sv
•I/O ports:
Signal name Width Direction Description
i_operand_a 32 input First operand for ALU operations.
i_operand_b 32 input Second operand for ALU operations.
i_alu_op 4 input The operation to be performed.
o_alu_data 32 output Result of the ALU operation.
3.2 Branch Comparison Unit (BRC)
3.2.1 Requirement
This unit is responsible for comparing two registers to determine the outcome of branch in-
structions. The unit should be capable of handling both signed and unsigned comparisons.
Note:Do not use built-in SystemVerilog operators for subtraction ( −), comparison ( <,>),
or shifting (≪,≫, and≫).
5
Milestone 2 — EE3043 Computer Architecture
3.2.2 Suggested specification
•Module name: brc.sv
•I/O ports:
Signal name Width Direction Description
i_rs1_data 32 input Data from the first register.
i_rs2_data 32 input Data from the second register.
i_br_un 1 input Comparison mode (1 if signed, 0 if unsigned).
o_br_less 1 output Output is 1 if 𝑟𝑠1<𝑟𝑠2.
o_br_equal 1 output Output is 1 if 𝑟𝑠1=𝑟𝑠2.
3.3 Regfile
3.3.1 Requirement
Implement a register file with 32 registers, each 32-bit wide. The register file must have two
read ports and one write port, with register 0 always reading as zero.
3.3.2 Suggested specification
•Module name: regfile.sv
•I/O ports:
Signal name Width Direction Description
i_clk 1 input Global clock.
i_rst 1 input Global active reset.
i_rs1_addr 5 input Address of the first source register.
i_rs2_addr 5 input Address of the second source register.
o_rs1_data 32 output Data from the first source register.
o_rs2_data 32 output Data from the second source register.
i_rd_addr 5 input Address of the destination register.
i_rd_data 32 input Data to write to the destination register.
i_rd_wren 1 input Write enable for the destination register.
3.4 I/O System and Memory
3.4.1 Memory Mapping
In real-world applications, a processor interfaces with peripheral devices to either transmit
data or receive data through the implementation of an Input/Output (I/O) System. Common
peripheral devices include LEDs, LCDs, and switches, among others. These peripherals es-
sentially function as a form of “memory” or “registers”. For instance, when a 32-bit register is
6
Milestone 2 — EE3043 Computer Architecture
linked to a set of 32 LEDs, depositing data into that register results in manipulating the state
of the LED array.
Memorymappingisastrategicmethodusedtoorganizethelayoutofmemorywithdifferent
memory regions serving specific functions. Figure 2 illustrates the memory map and the
register boundary addresses of some peripherals of STM32F030.
Figure 2: STM32F030 peripheral register boundary addresses
In this course, the traditional Data Memory is replaced by a Load-Store Unit (LSU), which
functions as an I/O System. The basic implementation of LSU is presented in Figure 3.
Input Buffer
Output Buffer
D$LSU
store data
store enable
load/store addressload datafrom switches
to LCD and LEDs
Figure 3: Load Store Unit
7
Milestone 2 — EE3043 Computer Architecture
3.4.2 Requirement
Implement a Load-Store Unit (LSU) to manage memory-mapped in Table 1.
Boundary address Mapping
0x7820 -- 0xFFFF (Reserved)
0x7810 -- 0x781F Buttons
0x7800 -- 0x780F Switches (required)
0x7040 -- 0x70FF (Reserved)
0x7030 -- 0x703F LCD Control Registers
0x7020 -- 0x7027 Seven-segment LEDs
0x7010 -- 0x701F Green LEDs (required)
0x7000 -- 0x700F Red LEDs (required)
0x4000 -- 0x6FFF (Reserved)
0x2000 -- 0x3FFF DataMemory(8KiBusingSDRAM) (required)
0x0000 -- 0x1FFF Instruction Memory (8KiB) (required)
Table 1: LSU memory mapping
Students are allowed to use reserved spaces for their own modifications.
3.4.3 Suggested specification
•Module name: lsu.sv
•I/O ports:
Signal name Width Direction Description
i_clk 1 input Global clock, active on the rising edge.
i_rst 1 input Global active reset.
i_lsu_addr 32 input Address for data read/write.
i_st_data 32 input Data to be stored.
i_lsu_wren 1 input Write enable signal (1 if writing).
o_ld_data 32 output Data read from memory.
o_io_ledr 32 output Output for red LEDs.
o_io_ledg 32 output Output for green LEDs.
o_io_hex0..7 7 output Output for 7-segment displays.
o_io_lcd 32 output Output for the LCD register.
i_io_sw 32 input Input for switches.
i_io_btn 4 input Input for buttons.
8
Milestone 2 — EE3043 Computer Architecture
3.4.4 Special considerations
1. Instruction memory should be 8KiB and initialized from a file named mem.dump file
located in 02_test/dump .
2. Data memory should be 8KiB using SDRAM or SRAM.
3. Memory write operations require a clock edge, whereas read operations do not.
4. The design doesn’t have to implement load (LB, LH, LBU, LHU) and store (SB, SH)
instructions, unless it supports seven-segments.
5.Warning1Thesignal o_insn_vld hastobeimplemented,forthegrandtestwilluseitas
ametrictodecideifyourdesignisrunningproperlyornot. Asthenamesuggests,ifthe
instruction is valid, it is set to 1.
3.5 Additional Components
You are also required to design a Control Unit and an Immediate Generator. Integrate these
components with the memory modules to complete your processor design.
4 Modified Processor
Youmayimplementamodifiedprocessordesigntoincorporateadditionalfeaturesoroptimiza-
tions. However, it is essential to first demonstrate a complete understanding of the standard
processor design. All modifications should be clearly documented and justified.
5 Verification
A comprehensive testbench is crucial for verifying the functionality of your processor. Your
testbench should cover a wide range of scenarios and corner cases to ensure thorough testing.
The TA will provide a final, comprehensive testbench for further validation one week before
the presentation. You are expected to create your testbenches and verify your design before
this point.
6 I/O System Conventions
For consistent operation and testing, adhere to the following conventions for setting up with
DE2 boards and interacting with the I/O system.
•LEDsUsetheoutputports o_io_ledr ando_io_ledg tocontroltheredandgreenLEDs,
respectively. These can be used for status indicators or debugging.
o_io_ledr
9
Milestone 2 — EE3043 Computer Architecture
Bits Usage
31 - 17 (Reserved)
16 - 0 17-bitdataconnectedtothearrayof17redLEDsinorder.
o_io_ledg
Bits Usage
31 - 8 (Reserved)
7 - 0 8-bitdataconnectedtothearrayof8greenLEDsinorder.
•Seven-Segment Utilize o_io_hex0..7 to display numerical values or messages. Each
port has 7 bits in total, so four of them can represent a 32-bit data as shown below. To
control each seven-segment display, stores a byte at the corresponding address, such as
SBat0x7022willchangethevalueofHEX2,while SHatthesamelocationwillaffectboth
HEX2 and HEX3. For the case of misaligned address, your assumption is critical.
Address 0x7020
Bits Usage
31 (Reserved)
30 - 24 7-bit data to HEX3.
23 (Reserved)
22 - 16 7-bit data to HEX2.
15 (Reserved)
14 - 8 7-bit data to HEX1.
7 (Reserved)
6 - 0 7-bit data to HEX0.
Address 0x7024
Bits Usage
31 (Reserved)
30 - 24 7-bit data to HEX7.
23 (Reserved)
22 - 16 7-bit data to HEX6.
15 (Reserved)
14 - 8 7-bit data to HEX5.
7 (Reserved)
6 - 0 7-bit data to HEX4.
•LCD Display Manage more complex visual output through o_io_lcd . To drive LCD
properly, visit this link to investigate the specification of LCD HD44780.
10
Milestone 2 — EE3043 Computer Architecture
Bits Usage
31 ON
30 - 11 (Reserved)
10 EN
9 RS
8 R/W
7 - 0 Data.
•Switches Use i_io_sw to receive input from external switches, which can be used for
user interaction or control signals.
Bits Usage
31 - 18 (Reserved)
17 Reset.
16 - 0 17-bit data from SW16 to SW0 respectively.
7 Applications
Developanapplicationthatutilizesthedesignedprocessor,demonstratingitscapabilitiesand
practicaluse. Thecomplexityandinnovationoftheapplicationwillimpactyourgrading. Sim-
pleapplicationsmightincludebasicinput/outputhandling,whilemoreadvancedapplications
could involve complex calculations or data processing.
Below are some example programs with its expected score:
1 ptDesign a stopwatch using seven-segment LEDs as the display.
1 ptConvertahexadecimalnumbertoadecimalnumberanddisplayonseven-segmentLEDs.
1.5 ptsConvert a hexadecimal number to its decimal and binary forms and display on LCD.
2 ptsInput32-DcoordinatesofA,B,andC.Determinewhichpoint,AorB,isclosertoCusing
LCD as the display.
8 Rubric
Your project will be evaluated based on the following criteria:
1.Baseline Submission – 5 pts: If your design successfully passes all provided test cases,
youwillearn5points. Pleaseensurethatyoursourcecodeissubmittedtotheserverfor
verification and transparency. No in-person presentation is required. If you choose not
to present your work, please indicate your consent in the Presentation sheet.
11
Milestone 2 — EE3043 Computer Architecture
2.Demonstration – 2 pts: Students who choose to present their project will, additionally,
receiveupto2points. Asuccessfuldemonstrationentailssynthesizingandimplementing
yourRISC-VprocessorontheDE2board,alongwithrunningapre-preparedapplication
onit. Thecomplexityandinnovationshowninyourdemonstrationwilldirectlyinfluence
your score.
3.Technical Enquiries – 2 pts: Each group member will be asked a question related to the
designandimplementationoftheirproject. Responseswillbeevaluatedbasedondepth
of understanding and clarity.
4.Advanced or Alternative Design – 1 pts: For students who incorporate substantial
modificationsorenhancementstothebaselineprocessordesign,upto1additionalpoint
will be awarded. The assessment will be based on the innovation, complexity, and
functionality of these improvements. It’s recommended to implement alternative or
advanced features early, as this effort will benefit you in Milestone 3.
8.1 Report
A comprehensive project report must be submitted, detailing the design process, challenges
faced, and solutions implemented. Refer to the report guidelines on Google Drive. The
report should be clear and concise, with sections for introduction, methodology, results, and
conclusions. Visual aids such as diagrams and charts are encouraged to illustrate key points.
12
