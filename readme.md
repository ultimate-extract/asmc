# Asmc Macro Assembler

## Change Log
- [source/asmc/history.txt](source/asmc/history.txt)

## Install Asmc

Download the zip-file or use Git:

    git clone https://github.com/nidud/asmc.git

For Windows run the asmc-2.34.cmd file in the root directory.

Linux:

    cd asmc/source/asmc
    make
    make install


Asmc Macro Assembler Reference

## Reference

- [Asmc Command-Line Reference](#asmc-command-line-reference)
Describes the Asmc command-line option.

- [Asmc Error Messages](#asmc-error-messages)
Describes Asmc fatal and nonfatal error messages and warnings.

- [Directives Reference](#directive-reference)
Provides links to topics discussing the use of directives in Asmc.

- [Symbols Reference](#symbols-reference)
Provides links to topics discussing the use of symbols in Asmc.

- [Operators Reference](#operators-reference)
Provides links to topics discussing the use of operators in Asmc.


## Asmc Command-Line Reference

Assembles and links one or more assembly-language source files. The command-line options are case sensitive.

**ASMC** [[options]] filename [[ [[options]] filename]]

_options_

The options listed in the following table.

| Option | Meaning |
| ------ |:------- |
| **-[0..10]**[p] | Set CPU: 0=8086 (default), 1=80186, 2=80286, 3=80386, 4=80486, 5=Pentium,6=PPro,7=P2,8=P3,9=P4,10=x86-64\. [p] allows privileged instructions. |
| **-arch**:_option_ | Specifies the architecture for code generation. Valid options are: IA32, SSE, SSE2, AVX, AVX2, and AVX512. |
| [**-assert**](#directive-assert) | Generate .assert(code). |
| **-autostack** | Calculate required stack space for arguments. |
| **-bin** | Generate plain binary file. |
| **-Cs** | Push user registers before [stack-frame](#option-cstack) is created in a proc. |
| **-coff** | Generate COFF format object file. |
| **-Cp** | Preserves case of all user identifiers. |
| **-Cu** | Maps all identifiers to upper case (default). |
| **-cui** | Link switch used with **-pe** -- subsystem:console (default). |
| **-Cx** | Preserves case in public and extern symbols. |
| **-D**_symbol_[[=_value_]] | Defines a text macro with the given name. If value is missing, it is blank. Multiple tokens separated by spaces must be enclosed in quotation marks. |
| **-dotname** | Allows names of identifiers to begin with a period. |
| **-e**_number_ | Set error limit number. |
| **-elf** | Generate 32-bit ELF object file. Defines _LINUX(1). |
| **-elf64** | Generate 64-bit ELF object file. Defines _LINUX(2) and _WIN64. |
| **-endbr** | Insert ENDBR instruction at function entry. |
| **-EP** | Generates a preprocessed source listing (sent to STDOUT). See /Sf. |
| **-eq** | Don't display error messages. |
| **-Fd**[_file_] | Write import definition file. |
| **-Fi**_file_ | Force _file_ to be included. |
| **-Fl**[[_filename_]] | Generates an assembled code listing. See /Sf. |
| **-Fo**_filename_ | Names an object file. In case of wildcard '*' may be used for current file. |
| **-fpc** | Disallow floating-point instructions. |
| **-FPi** | Generates emulator fix-ups for floating-point arithmetic (mixed language only). |
| **-FPi87** | 80x87 instructions (default). |
| **-fpic**, **-fno-pic** | Enables or disables the generation of position-independent code for ELF64. Defualt is **-fno-pic**. |
| **-fp**_n_ | Set FPU: 0=8087, 2=80287, 3=80387. |
| **-frame** | Auto generate unwind information. |
| **-Fw**_filename_ | Set errors file name. |
| **-Gc** | Specifies use of FORTRAN- or Pascal-style function calling and naming conventions. Same as **OPTION LANGUAGE:PASCAL**. |
| **-Gd** | Specifies use of C-style function calling and naming conventions. Same as **OPTION LANGUAGE:C**. |
| **-Gs** | Specifies use of SYSCALL (System V)-style function calling and naming conventions. Same as **OPTION LANGUAGE:SYSCALL**. |
| **-Ge** | Emit a conditional _chkstk() inside the prologue. |
| **-gui** | Link switch used with **-pe** -- subsystem:windows. |
| **-Gv** | Specifies use of VECTORCALL-style function calling and naming conventions. |
| **-Gz** | Specifies use of STDCALL-style function calling and naming conventions. Defines _STDCALL_SUPPORTED. Same as **OPTION LANGUAGE:STDCALL**. |
| **-homeparams** | Forces parameters passed in registers to be written to their locations on the stack upon function entry. |
| **-I**_pathname_ | Sets path for include file. |
| **-idd** | Assemble source as binary data. |
| **-iddt** | Assemble source as text file. |
| **-logo** | Print logo string and exit. |
| **-MD[d]** | Defines _MSVCRT [_DEBUG]. |
| **-MT[d]** | Defines _MT [_DEBUG]. |
| **-m**[_tscmlhf_] | Set memory model. |
| **-mz** | Generate DOS MZ binary file. |
| **-nc**_name_ | Set class name of code segment. |
| **-nd**_name_ | Set name of data segment. |
| **-nm**_name_ | Set name of module. |
| **-nt**_name_ | Set name of text segment. |
| **-nolib** | Ignore INCLUDELIB directive. |
| **-nologo** | Suppresses messages for successful assembly. |
| **-omf** | Generates object module file format (OMF) type of object module. |
| **-pe** | Generate PE binary file, 32/64-bit. |
| **-q** | Suppress copyright message. |
| **-r** | Recurse subdirectories with use of wildcards. |
| **-Sa** | Turns on listing of all available information. |
| **-safeseh** | Marks the object as either containing no exception handlers or containing exception handlers that are all declared with SAFESEH. |
| **-Sf** | Adds first-pass listing to listing file. |
| **-Sg** | Turns on listing of assembly-generated code. |
| **-Sn** | Turns off symbol table when producing a listing. |
| **-Sp**[n] | Set segment alignment. |
| **-stackalign** | Align stack variables to 16-byte. |
| **-sysvregs** | Ignore RDI and RSI in USES for Linux64. |
| **-Sx** | Turns on false conditionals in listing. |
| **-w** | Same as /W0. |
| **-W**_level_ | Sets the warning level, where _level_ = 0, 1, 2, or 3.|
| **-win64** | Generate 64-bit COFF object. Defines _WIN64. |
| [**-ws**](#option-wstring)[_CodePage_] | Store quoted strings as Unicode. Defines _UNICODE. |
| **-WX** | Returns an error code if warnings are generated. |
| **-X** | Ignore INCLUDE environment path. |
| **-Z7** | Add full symbolic debugging information. |
| **-zcw** | No decoration for C symbols. |
| **-Zd** | Generates line-number information in object file. |
| **-Zf** | Make all symbols public. |
| **-zf**[01] | Set FASTCALL type: MS/OW. |
| **-Zg** | Generate code to match Masm. |
| [**-Zi**](#add-symbolic-debugging-information) | Add symbolic debugging information. |
| **-zlc** | No OMF records of data in code. |
| **-zld** | No OMF records of far call. |
| **-zlf** | Suppress items in COFF: No file entry. |
| **-zlp** | Suppress items in COFF: No static procs. |
| **-zls** | Suppress items in COFF: No section aux entry. |
| **-Zm** | Enable MASM 5.10 compatibility. |
| **-Zp**[[_alignment_]] | Packs structures on the specified byte boundary. |
| **-Zs** | Perform syntax check only. |
| **-zt**[012] | Set STDCALL decoration. |
| **-Zv8** | Enable Masm v8+ PROC visibility. |
| **-zze** | No export symbol decoration. |
| **-zzs** | Store name of start address. |
| _filename_ | The name of the file. |


### Environment Variables

| | |
| -------- |:------- |
| **INCLUDE** | Specifies search path for include files. |
| **ASMC** | Specifies default command-line options. |
| **TEMP** | Specifies path for temporary files. |

**See Also**

[Predefined Macros](#predefined-macros)


### Add Symbolic Debugging Information

    Command-line options /Zi

#### CodeView Symbolic Debug

Asmc allows in addition to CV4 (default), CV5 and CV8 debug format.

    Options for CV4

    /Zi0    globals
    /Zi1    globals and locals
    /Zi2    globals, locals and types (default (/Zi))
    /Zi3    globals, locals, types and constants

    Options for CV5

    /Zi[n]5

    Options for CV8

    /Zi[n]8


## Asmc Error Messages


## Directives Reference


## Symbols Reference
