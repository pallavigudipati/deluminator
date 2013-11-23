// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

// Challenge!
#include <kern/pmap.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Backtraces.", mon_backtrace },
	{ "showmappings", "Shows mappings for a given virtual address.",
	  mon_showmappings },
	{ "changeperm", "Change permissions of a given virtual address.",
	  mon_changeperm },
	{ "dump", "Dumps memory.", mon_dump },
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/
// Challenge!
int mon_showmappings(int argc, char** argv, struct Trapframe *tf) {
	int start_va, end_va;
	if (argc != 3) {
		cprintf("Invalid number of arguments.\n");
		return 1;
	}
	start_va = strtol(argv[1], NULL, 0);
	end_va = strtol(argv[2], NULL, 0);
	start_va = ROUNDUP(start_va, PGSIZE);
	end_va = ROUNDUP(end_va, PGSIZE);
	showmappings(start_va, end_va);
	return 0;
}

// Challenge!
int mon_changeperm(int argc, char** argv, struct Trapframe *tf) {
	if (argc != 3) {
		cprintf("Invalid number of arguments\n");
	}
	int va = strtol(argv[1], NULL, 0);
	va = ROUNDUP(va, PGSIZE);
	int perm = 0;
	int set = 1;
	if (argv[2][0] == 'u') {
		perm = PTE_U;
		set = 1;
	} else if (argv[2][0] == 'p') {
		perm = PTE_P;
		set = 1;
	} else if (argv[2][0] == 'w') {
		perm = PTE_W;
		set = 1;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'u') {
		perm = ~PTE_U;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'w') {
		perm = ~PTE_W;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'p') {
		perm = ~PTE_P;
		set = 0;
	} else {
		cprintf("Invalid arguments\n");
		return 1;
	}
	
	change_perm(va, perm, set);
	return 0;
}

// Challenge!
int mon_dump(int argc, char** argv, struct Trapframe *tf) {
	if (argc != 4) {
		cprintf("Invalid number of arguments\n");
		return 1;
	}
	int start_va = strtol(argv[1], NULL, 0);
	int end_va = strtol(argv[2], NULL, 0);
	int i = 0;
	if (argv[3][0] == 'p') {
		if (start_va > 0xffffffff - KERNBASE ||
			end_va > 0xffffffff - KERNBASE) {
			cprintf("Invalid arguments\n");
			return 1;
		}
		start_va = (int)KADDR(start_va);
		end_va = (int)KADDR(end_va);	
		for (i = start_va; i <= end_va; i += 4) {
			cprintf("0x%x: 0x%x\n", i - KERNBASE, *((int*)i));
		}
		return 0;
	} else if (argv[3][0] != 'v') {
		cprintf("Invalid arguments\n");
		return -1;
	}

	start_va = ROUNDUP(start_va, 4);
	end_va = ROUNDUP(end_va, 4);

	dump_memory(start_va, end_va);
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t eip, arg1, arg2, arg3, arg4, arg5;	
	cprintf("Stack backtrace:\n");
	uint32_t* ebp_address = (uint32_t*) read_ebp();
	int temp;
	int i = 0;
	while ((uint32_t)ebp_address != 0) {
		struct Eipdebuginfo info;
		eip = *(ebp_address + 1);
		arg1 = *(ebp_address + 2);
		arg2 = *(ebp_address + 3);
		arg3 = *(ebp_address + 4);
		arg4 = *(ebp_address + 5);
		arg5 = *(ebp_address + 6);
		temp = debuginfo_eip(eip, &info);
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
				(uint32_t)ebp_address, eip, arg1, arg2, arg3, arg4, arg5);
		cprintf("\t%s:%d: ", info.eip_file, info.eip_line);
		cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
		cprintf("+%d\n", eip - info.eip_fn_addr);
		
		ebp_address = (uint32_t*)(*ebp_address);
		i++;
	}
	
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
