# Milestone 2 Notes

- Current LSU supports word-aligned SW/LW only (8 KiB RAM @ 0x2000–0x3FFF) per special consideration #4.
- Byte/halfword operations (LB/LH/LBU/LHU/SB/SH) are not implemented yet.
- Seven-seg (0x7020–0x7027) and LCD (0x7030–0x703F) are stubbed:
  - Writes are accepted (safe stubs); reads return zero.
  - When seven-seg is fully implemented per bitfield maps, we will add byte/halfword support and define misaligned access policy.

