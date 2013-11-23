/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

/*TODO check the error code popping */

	TRAPHANDLER_NOEC(trap0, T_DIVIDE);
	TRAPHANDLER_NOEC(trap1, T_DEBUG);
	TRAPHANDLER_NOEC(trap2, T_NMI);
	TRAPHANDLER_NOEC(trap3, T_BRKPT);
	TRAPHANDLER_NOEC(trap4, T_OFLOW);
	TRAPHANDLER_NOEC(trap5, T_BOUND);
	TRAPHANDLER_NOEC(trap6, T_ILLOP);
	TRAPHANDLER_NOEC(trap7, T_DEVICE);
	TRAPHANDLER_NOEC(trap8, T_DBLFLT);
	TRAPHANDLER_NOEC(trap9, 9);
	TRAPHANDLER(trap10, T_TSS);
	TRAPHANDLER(trap11, T_SEGNP);
	TRAPHANDLER(trap12, T_STACK);
	TRAPHANDLER(trap13, T_GPFLT);
	TRAPHANDLER(trap14, T_PGFLT);
	TRAPHANDLER_NOEC(trap15, 15);
	TRAPHANDLER_NOEC(trap16, T_FPERR);
	TRAPHANDLER_NOEC(trap17, T_ALIGN);
	TRAPHANDLER_NOEC(trap18, T_MCHK);
	TRAPHANDLER_NOEC(trap19, T_SIMDERR);
	TRAPHANDLER_NOEC(trap20, 20);
	TRAPHANDLER_NOEC(trap21, 21);
	TRAPHANDLER_NOEC(trap22, 22);
	TRAPHANDLER_NOEC(trap23, 23);
	TRAPHANDLER_NOEC(trap24, 24);
	TRAPHANDLER_NOEC(trap25, 25);
	TRAPHANDLER_NOEC(trap26, 26);
	TRAPHANDLER_NOEC(trap27, 27);
	TRAPHANDLER_NOEC(trap28, 28);
	TRAPHANDLER_NOEC(trap29, 29);
	TRAPHANDLER_NOEC(trap30, 30);
	TRAPHANDLER_NOEC(trap31, 31);
	TRAPHANDLER_NOEC(trap32, IRQ_OFFSET + IRQ_TIMER);
	TRAPHANDLER_NOEC(trap33, IRQ_OFFSET + IRQ_KBD);
	TRAPHANDLER_NOEC(trap34, 34);
	TRAPHANDLER_NOEC(trap35, 35);
	TRAPHANDLER_NOEC(trap36, IRQ_OFFSET + IRQ_SERIAL);
	TRAPHANDLER_NOEC(trap37, 37);
	TRAPHANDLER_NOEC(trap38, 38);
	TRAPHANDLER_NOEC(trap39, IRQ_OFFSET + IRQ_SPURIOUS);
	TRAPHANDLER_NOEC(trap40, 40);
	TRAPHANDLER_NOEC(trap41, 41);
	TRAPHANDLER_NOEC(trap42, 42);
	TRAPHANDLER_NOEC(trap43, 43);
	TRAPHANDLER_NOEC(trap44, 44);
	TRAPHANDLER_NOEC(trap45, 45);
	TRAPHANDLER_NOEC(trap46, IRQ_OFFSET + IRQ_IDE);
	TRAPHANDLER_NOEC(trap47, 47);
	TRAPHANDLER_NOEC(trap48, T_SYSCALL);
	TRAPHANDLER_NOEC(trap49, 49);
	TRAPHANDLER_NOEC(trap50, 50);
	TRAPHANDLER_NOEC(trap51, IRQ_OFFSET + IRQ_ERROR);
	TRAPHANDLER_NOEC(trap52, 52);
/*
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
	pushl %es
	pushal

	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap

.data
.globl traps
traps:
	.long trap0	
	.long trap1	
	.long trap2	
	.long trap3	
	.long trap4	
	.long trap5	
	.long trap6	
	.long trap7	
	.long trap8	
	.long trap9	
	.long trap10	
	.long trap11	
	.long trap12
	.long trap13
	.long trap14
	.long trap15
	.long trap16
	.long trap17
	.long trap18	
	.long trap19
	.long trap20
	.long trap21
	.long trap22
	.long trap23
	.long trap24
	.long trap25
	.long trap26
	.long trap27
	.long trap28
	.long trap29
	.long trap30
	.long trap31
	.long trap32
	.long trap33
	.long trap34
	.long trap35
	.long trap36
	.long trap37
	.long trap38
	.long trap39
	.long trap40
	.long trap41
	.long trap42
	.long trap43
	.long trap44
	.long trap45
	.long trap46
	.long trap47
	.long trap48
	.long trap49
	.long trap50
	.long trap51
	.long trap52

