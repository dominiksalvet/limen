# Limen

![Limen pipeline](img/pipeline.png)

Limen processor was initiated in 2015 and was later used within [my high school thesis](https://is.muni.cz/publication/1491040/en). It uses 16-bit RISC core architecture with von Neumann memory architecture. It was written in VHDL (with tab size 3!) and tested on an FPGA (Digilent Basys 2). Significant characteristics:

* Smallest addressable unit is 2 bytes
* May address up to 128 KB of memory
* 8 x 16-bit general purpose registers (R0 is always 0)
* No status register for arithmetic operations
* Defines 8 instruction formats

The microarchitecture itself is rather simple and straightforward – no pipelining involved. Feel free to look around the source code!

> Did you know that [Limen Alpha](https://github.com/dominiksalvet/limen-alpha) is its dual-core successor?

## Machine Code

If you are curious how the machine code of Limen looks like, browse the [collection of such programs](sw).

## Useful Resources

* [support.md](support.md) – questions, answers, help
* [contributing.md](contributing.md) – how to get involve
* [license](license) – author and license
