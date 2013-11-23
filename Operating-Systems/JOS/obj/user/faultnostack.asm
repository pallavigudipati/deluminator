
obj/user/faultnostack:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 50 04 80 	movl   $0x800450,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 13 03 00 00       	call   800361 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
  80005a:	66 90                	xchg   %ax,%ax

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800075:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800078:	e8 0b 01 00 00       	call   800188 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x3e>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80009e:	89 1c 24             	mov    %ebx,(%esp)
  8000a1:	e8 8e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0d 00 00 00       	call   8000b8 <exit>
}
  8000ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b1:	89 ec                	mov    %ebp,%esp
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    
  8000b5:	66 90                	xchg   %ax,%ax
  8000b7:	90                   	nop

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 61 00 00 00       	call   80012b <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e6:	89 c3                	mov    %eax,%ebx
  8000e8:	89 c7                	mov    %eax,%edi
  8000ea:	89 c6                	mov    %eax,%esi
  8000ec:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000f7:	89 ec                	mov    %ebp,%esp
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800104:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800107:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	ba 00 00 00 00       	mov    $0x0,%edx
  80010f:	b8 01 00 00 00       	mov    $0x1,%eax
  800114:	89 d1                	mov    %edx,%ecx
  800116:	89 d3                	mov    %edx,%ebx
  800118:	89 d7                	mov    %edx,%edi
  80011a:	89 d6                	mov    %edx,%esi
  80011c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800121:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800124:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800127:	89 ec                	mov    %ebp,%esp
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 38             	sub    $0x38,%esp
  800131:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800134:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800137:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013f:	b8 03 00 00 00       	mov    $0x3,%eax
  800144:	8b 55 08             	mov    0x8(%ebp),%edx
  800147:	89 cb                	mov    %ecx,%ebx
  800149:	89 cf                	mov    %ecx,%edi
  80014b:	89 ce                	mov    %ecx,%esi
  80014d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80014f:	85 c0                	test   %eax,%eax
  800151:	7e 28                	jle    80017b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800153:	89 44 24 10          	mov    %eax,0x10(%esp)
  800157:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80015e:	00 
  80015f:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  800166:	00 
  800167:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80016e:	00 
  80016f:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  800176:	e8 0d 03 00 00       	call   800488 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80017b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80017e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800181:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800184:	89 ec                	mov    %ebp,%esp
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800191:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800194:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800197:	ba 00 00 00 00       	mov    $0x0,%edx
  80019c:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a1:	89 d1                	mov    %edx,%ecx
  8001a3:	89 d3                	mov    %edx,%ebx
  8001a5:	89 d7                	mov    %edx,%edi
  8001a7:	89 d6                	mov    %edx,%esi
  8001a9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_yield>:

void
sys_yield(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001d1:	89 d1                	mov    %edx,%ecx
  8001d3:	89 d3                	mov    %edx,%ebx
  8001d5:	89 d7                	mov    %edx,%edi
  8001d7:	89 d6                	mov    %edx,%esi
  8001d9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001db:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001de:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001e4:	89 ec                	mov    %ebp,%esp
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 38             	sub    $0x38,%esp
  8001ee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001f1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001f4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f7:	be 00 00 00 00       	mov    $0x0,%esi
  8001fc:	b8 04 00 00 00       	mov    $0x4,%eax
  800201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800204:	8b 55 08             	mov    0x8(%ebp),%edx
  800207:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020a:	89 f7                	mov    %esi,%edi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 28                	jle    80023a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	89 44 24 10          	mov    %eax,0x10(%esp)
  800216:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80021d:	00 
  80021e:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  800225:	00 
  800226:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80022d:	00 
  80022e:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  800235:	e8 4e 02 00 00       	call   800488 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80023a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80023d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800240:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800243:	89 ec                	mov    %ebp,%esp
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 38             	sub    $0x38,%esp
  80024d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800250:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800253:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800256:	b8 05 00 00 00       	mov    $0x5,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800264:	8b 7d 14             	mov    0x14(%ebp),%edi
  800267:	8b 75 18             	mov    0x18(%ebp),%esi
  80026a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80026c:	85 c0                	test   %eax,%eax
  80026e:	7e 28                	jle    800298 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	89 44 24 10          	mov    %eax,0x10(%esp)
  800274:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80027b:	00 
  80027c:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  800283:	00 
  800284:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80028b:	00 
  80028c:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  800293:	e8 f0 01 00 00       	call   800488 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800298:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80029b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80029e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002a1:	89 ec                	mov    %ebp,%esp
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 38             	sub    $0x38,%esp
  8002ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 df                	mov    %ebx,%edi
  8002c6:	89 de                	mov    %ebx,%esi
  8002c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	7e 28                	jle    8002f6 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002d9:	00 
  8002da:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e9:	00 
  8002ea:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  8002f1:	e8 92 01 00 00       	call   800488 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ff:	89 ec                	mov    %ebp,%esp
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 38             	sub    $0x38,%esp
  800309:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80030c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80030f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800312:	bb 00 00 00 00       	mov    $0x0,%ebx
  800317:	b8 08 00 00 00       	mov    $0x8,%eax
  80031c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
  800322:	89 df                	mov    %ebx,%edi
  800324:	89 de                	mov    %ebx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 28                	jle    800354 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800330:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800337:	00 
  800338:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  80033f:	00 
  800340:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800347:	00 
  800348:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  80034f:	e8 34 01 00 00       	call   800488 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800354:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800357:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80035a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80035d:	89 ec                	mov    %ebp,%esp
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 38             	sub    $0x38,%esp
  800367:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80036a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80036d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800370:	bb 00 00 00 00       	mov    $0x0,%ebx
  800375:	b8 09 00 00 00       	mov    $0x9,%eax
  80037a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037d:	8b 55 08             	mov    0x8(%ebp),%edx
  800380:	89 df                	mov    %ebx,%edi
  800382:	89 de                	mov    %ebx,%esi
  800384:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800386:	85 c0                	test   %eax,%eax
  800388:	7e 28                	jle    8003b2 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80038e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800395:	00 
  800396:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  80039d:	00 
  80039e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a5:	00 
  8003a6:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  8003ad:	e8 d6 00 00 00       	call   800488 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003bb:	89 ec                	mov    %ebp,%esp
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	83 ec 0c             	sub    $0xc,%esp
  8003c5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003c8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003cb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ce:	be 00 00 00 00       	mov    $0x0,%esi
  8003d3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003db:	8b 55 08             	mov    0x8(%ebp),%edx
  8003de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003e4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003ef:	89 ec                	mov    %ebp,%esp
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	83 ec 38             	sub    $0x38,%esp
  8003f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	b8 0c 00 00 00       	mov    $0xc,%eax
  80040c:	8b 55 08             	mov    0x8(%ebp),%edx
  80040f:	89 cb                	mov    %ecx,%ebx
  800411:	89 cf                	mov    %ecx,%edi
  800413:	89 ce                	mov    %ecx,%esi
  800415:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800417:	85 c0                	test   %eax,%eax
  800419:	7e 28                	jle    800443 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800426:	00 
  800427:	c7 44 24 08 6a 13 80 	movl   $0x80136a,0x8(%esp)
  80042e:	00 
  80042f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800436:	00 
  800437:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  80043e:	e8 45 00 00 00       	call   800488 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800443:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800446:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800449:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80044c:	89 ec                	mov    %ebp,%esp
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800450:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800451:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800456:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800458:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	popl %eax
  80045b:	58                   	pop    %eax
	popl %eax
  80045c:	58                   	pop    %eax
	
	addl $32, %esp
  80045d:	83 c4 20             	add    $0x20,%esp
	movl (%esp), %eax
  800460:	8b 04 24             	mov    (%esp),%eax
	addl $8, %esp
  800463:	83 c4 08             	add    $0x8,%esp
	movl (%esp), %ebx
  800466:	8b 1c 24             	mov    (%esp),%ebx
	subl $4, %ebx
  800469:	83 eb 04             	sub    $0x4,%ebx

	movl %ebx, (%esp)
  80046c:	89 1c 24             	mov    %ebx,(%esp)

	movl %eax, (%ebx)
  80046f:	89 03                	mov    %eax,(%ebx)
	subl $40, %esp
  800471:	83 ec 28             	sub    $0x28,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	popl %edi
  800474:	5f                   	pop    %edi
	popl %esi
  800475:	5e                   	pop    %esi
	popl %ebp
  800476:	5d                   	pop    %ebp
	addl $4, %esp
  800477:	83 c4 04             	add    $0x4,%esp
	popl %ebx
  80047a:	5b                   	pop    %ebx
	popl %edx
  80047b:	5a                   	pop    %edx
	popl %ecx
  80047c:	59                   	pop    %ecx
	popl %eax
  80047d:	58                   	pop    %eax
	addl $4, %esp
  80047e:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl
  800481:	9d                   	popf   
	
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	movl (%esp), %esp
  800482:	8b 24 24             	mov    (%esp),%esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800485:	c3                   	ret    
  800486:	66 90                	xchg   %ax,%ax

00800488 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	56                   	push   %esi
  80048c:	53                   	push   %ebx
  80048d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800490:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800493:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800499:	e8 ea fc ff ff       	call   800188 <sys_getenvid>
  80049e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ac:	89 74 24 08          	mov    %esi,0x8(%esp)
  8004b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b4:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  8004bb:	e8 c3 00 00 00       	call   800583 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	e8 53 00 00 00       	call   800522 <vcprintf>
	cprintf("\n");
  8004cf:	c7 04 24 06 16 80 00 	movl   $0x801606,(%esp)
  8004d6:	e8 a8 00 00 00       	call   800583 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004db:	cc                   	int3   
  8004dc:	eb fd                	jmp    8004db <_panic+0x53>
  8004de:	66 90                	xchg   %ax,%ax

008004e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 14             	sub    $0x14,%esp
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ea:	8b 03                	mov    (%ebx),%eax
  8004ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004f3:	83 c0 01             	add    $0x1,%eax
  8004f6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004fd:	75 19                	jne    800518 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004ff:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800506:	00 
  800507:	8d 43 08             	lea    0x8(%ebx),%eax
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	e8 ba fb ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  800512:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800518:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80051c:	83 c4 14             	add    $0x14,%esp
  80051f:	5b                   	pop    %ebx
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    

00800522 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80052b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800532:	00 00 00 
	b.cnt = 0;
  800535:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80053c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
  800557:	c7 04 24 e0 04 80 00 	movl   $0x8004e0,(%esp)
  80055e:	e8 af 01 00 00       	call   800712 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800563:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 51 fb ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  80057b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800589:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 87 ff ff ff       	call   800522 <vcprintf>
	va_end(ap);

	return cnt;
}
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    
  80059d:	66 90                	xchg   %ax,%ax
  80059f:	90                   	nop

008005a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 4c             	sub    $0x4c,%esp
  8005a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005ac:	89 d7                	mov    %edx,%edi
  8005ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	39 d8                	cmp    %ebx,%eax
  8005c1:	72 17                	jb     8005da <printnum+0x3a>
  8005c3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005c6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8005c9:	76 0f                	jbe    8005da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005cb:	8b 75 14             	mov    0x14(%ebp),%esi
  8005ce:	83 ee 01             	sub    $0x1,%esi
  8005d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d4:	85 f6                	test   %esi,%esi
  8005d6:	7f 63                	jg     80063b <printnum+0x9b>
  8005d8:	eb 75                	jmp    80064f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005da:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8005dd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	83 e8 01             	sub    $0x1,%eax
  8005e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005f2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005f6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800600:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800607:	00 
  800608:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80060b:	89 1c 24             	mov    %ebx,(%esp)
  80060e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800615:	e8 66 0a 00 00       	call   801080 <__udivdi3>
  80061a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800620:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800624:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062f:	89 fa                	mov    %edi,%edx
  800631:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800634:	e8 67 ff ff ff       	call   8005a0 <printnum>
  800639:	eb 14                	jmp    80064f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063f:	8b 45 18             	mov    0x18(%ebp),%eax
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800647:	83 ee 01             	sub    $0x1,%esi
  80064a:	75 ef                	jne    80063b <printnum+0x9b>
  80064c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800653:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800657:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80065a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80065e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800665:	00 
  800666:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800669:	89 1c 24             	mov    %ebx,(%esp)
  80066c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	e8 58 0b 00 00       	call   8011d0 <__umoddi3>
  800678:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067c:	0f be 80 bb 13 80 00 	movsbl 0x8013bb(%eax),%eax
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800689:	ff d0                	call   *%eax
}
  80068b:	83 c4 4c             	add    $0x4c,%esp
  80068e:	5b                   	pop    %ebx
  80068f:	5e                   	pop    %esi
  800690:	5f                   	pop    %edi
  800691:	5d                   	pop    %ebp
  800692:	c3                   	ret    

00800693 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800696:	83 fa 01             	cmp    $0x1,%edx
  800699:	7e 0e                	jle    8006a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a0:	89 08                	mov    %ecx,(%eax)
  8006a2:	8b 02                	mov    (%edx),%eax
  8006a4:	8b 52 04             	mov    0x4(%edx),%edx
  8006a7:	eb 22                	jmp    8006cb <getuint+0x38>
	else if (lflag)
  8006a9:	85 d2                	test   %edx,%edx
  8006ab:	74 10                	je     8006bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b2:	89 08                	mov    %ecx,(%eax)
  8006b4:	8b 02                	mov    (%edx),%eax
  8006b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bb:	eb 0e                	jmp    8006cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c2:	89 08                	mov    %ecx,(%eax)
  8006c4:	8b 02                	mov    (%edx),%eax
  8006c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8006dc:	73 0a                	jae    8006e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e1:	88 0a                	mov    %cl,(%edx)
  8006e3:	83 c2 01             	add    $0x1,%edx
  8006e6:	89 10                	mov    %edx,(%eax)
}
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800701:	89 44 24 04          	mov    %eax,0x4(%esp)
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	e8 02 00 00 00       	call   800712 <vprintfmt>
	va_end(ap);
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	57                   	push   %edi
  800716:	56                   	push   %esi
  800717:	53                   	push   %ebx
  800718:	83 ec 4c             	sub    $0x4c,%esp
  80071b:	8b 75 08             	mov    0x8(%ebp),%esi
  80071e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800721:	8b 7d 10             	mov    0x10(%ebp),%edi
  800724:	eb 11                	jmp    800737 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800726:	85 c0                	test   %eax,%eax
  800728:	0f 84 db 03 00 00    	je     800b09 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	89 04 24             	mov    %eax,(%esp)
  800735:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800737:	0f b6 07             	movzbl (%edi),%eax
  80073a:	83 c7 01             	add    $0x1,%edi
  80073d:	83 f8 25             	cmp    $0x25,%eax
  800740:	75 e4                	jne    800726 <vprintfmt+0x14>
  800742:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800746:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80074d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800754:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 2b                	jmp    80078d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800762:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800765:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800769:	eb 22                	jmp    80078d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80076e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800772:	eb 19                	jmp    80078d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800777:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80077e:	eb 0d                	jmp    80078d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800780:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800783:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800786:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	0f b6 0f             	movzbl (%edi),%ecx
  800790:	8d 47 01             	lea    0x1(%edi),%eax
  800793:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800796:	0f b6 07             	movzbl (%edi),%eax
  800799:	83 e8 23             	sub    $0x23,%eax
  80079c:	3c 55                	cmp    $0x55,%al
  80079e:	0f 87 40 03 00 00    	ja     800ae4 <vprintfmt+0x3d2>
  8007a4:	0f b6 c0             	movzbl %al,%eax
  8007a7:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007ae:	83 e9 30             	sub    $0x30,%ecx
  8007b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8007b4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8007b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007bb:	83 f9 09             	cmp    $0x9,%ecx
  8007be:	77 57                	ja     800817 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007cc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8007cf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8007d3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007d6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007d9:	83 f9 09             	cmp    $0x9,%ecx
  8007dc:	76 eb                	jbe    8007c9 <vprintfmt+0xb7>
  8007de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007e4:	eb 34                	jmp    80081a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007f7:	eb 21                	jmp    80081a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8007f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007fd:	0f 88 71 ff ff ff    	js     800774 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800803:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800806:	eb 85                	jmp    80078d <vprintfmt+0x7b>
  800808:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80080b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800812:	e9 76 ff ff ff       	jmp    80078d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800817:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80081a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80081e:	0f 89 69 ff ff ff    	jns    80078d <vprintfmt+0x7b>
  800824:	e9 57 ff ff ff       	jmp    800780 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800829:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80082f:	e9 59 ff ff ff       	jmp    80078d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8d 50 04             	lea    0x4(%eax),%edx
  80083a:	89 55 14             	mov    %edx,0x14(%ebp)
  80083d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800841:	8b 00                	mov    (%eax),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80084b:	e9 e7 fe ff ff       	jmp    800737 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 00                	mov    (%eax),%eax
  80085b:	89 c2                	mov    %eax,%edx
  80085d:	c1 fa 1f             	sar    $0x1f,%edx
  800860:	31 d0                	xor    %edx,%eax
  800862:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800864:	83 f8 08             	cmp    $0x8,%eax
  800867:	7f 0b                	jg     800874 <vprintfmt+0x162>
  800869:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800870:	85 d2                	test   %edx,%edx
  800872:	75 20                	jne    800894 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800874:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800878:	c7 44 24 08 d3 13 80 	movl   $0x8013d3,0x8(%esp)
  80087f:	00 
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	89 34 24             	mov    %esi,(%esp)
  800887:	e8 5e fe ff ff       	call   8006ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80088f:	e9 a3 fe ff ff       	jmp    800737 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800894:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800898:	c7 44 24 08 dc 13 80 	movl   $0x8013dc,0x8(%esp)
  80089f:	00 
  8008a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a4:	89 34 24             	mov    %esi,(%esp)
  8008a7:	e8 3e fe ff ff       	call   8006ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8008af:	e9 83 fe ff ff       	jmp    800737 <vprintfmt+0x25>
  8008b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008b7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8008c8:	85 ff                	test   %edi,%edi
  8008ca:	b8 cc 13 80 00       	mov    $0x8013cc,%eax
  8008cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8008d2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8008d6:	74 06                	je     8008de <vprintfmt+0x1cc>
  8008d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008dc:	7f 16                	jg     8008f4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008de:	0f b6 17             	movzbl (%edi),%edx
  8008e1:	0f be c2             	movsbl %dl,%eax
  8008e4:	83 c7 01             	add    $0x1,%edi
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	0f 85 9f 00 00 00    	jne    80098e <vprintfmt+0x27c>
  8008ef:	e9 8b 00 00 00       	jmp    80097f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008f8:	89 3c 24             	mov    %edi,(%esp)
  8008fb:	e8 c2 02 00 00       	call   800bc2 <strnlen>
  800900:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800903:	29 c2                	sub    %eax,%edx
  800905:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800908:	85 d2                	test   %edx,%edx
  80090a:	7e d2                	jle    8008de <vprintfmt+0x1cc>
					putch(padc, putdat);
  80090c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800910:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800913:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800916:	89 d7                	mov    %edx,%edi
  800918:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800924:	83 ef 01             	sub    $0x1,%edi
  800927:	75 ef                	jne    800918 <vprintfmt+0x206>
  800929:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80092c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80092f:	eb ad                	jmp    8008de <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800931:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800935:	74 20                	je     800957 <vprintfmt+0x245>
  800937:	0f be d2             	movsbl %dl,%edx
  80093a:	83 ea 20             	sub    $0x20,%edx
  80093d:	83 fa 5e             	cmp    $0x5e,%edx
  800940:	76 15                	jbe    800957 <vprintfmt+0x245>
					putch('?', putdat);
  800942:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800945:	89 54 24 04          	mov    %edx,0x4(%esp)
  800949:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800950:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800953:	ff d1                	call   *%ecx
  800955:	eb 0f                	jmp    800966 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800957:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80095a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095e:	89 04 24             	mov    %eax,(%esp)
  800961:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800964:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800966:	83 eb 01             	sub    $0x1,%ebx
  800969:	0f b6 17             	movzbl (%edi),%edx
  80096c:	0f be c2             	movsbl %dl,%eax
  80096f:	83 c7 01             	add    $0x1,%edi
  800972:	85 c0                	test   %eax,%eax
  800974:	75 24                	jne    80099a <vprintfmt+0x288>
  800976:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800979:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80097c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800982:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800986:	0f 8e ab fd ff ff    	jle    800737 <vprintfmt+0x25>
  80098c:	eb 20                	jmp    8009ae <vprintfmt+0x29c>
  80098e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800991:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800994:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800997:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099a:	85 f6                	test   %esi,%esi
  80099c:	78 93                	js     800931 <vprintfmt+0x21f>
  80099e:	83 ee 01             	sub    $0x1,%esi
  8009a1:	79 8e                	jns    800931 <vprintfmt+0x21f>
  8009a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8009a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009ac:	eb d1                	jmp    80097f <vprintfmt+0x26d>
  8009ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	75 ee                	jne    8009b1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8009c6:	e9 6c fd ff ff       	jmp    800737 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009cb:	83 fa 01             	cmp    $0x1,%edx
  8009ce:	66 90                	xchg   %ax,%ax
  8009d0:	7e 16                	jle    8009e8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8009d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d5:	8d 50 08             	lea    0x8(%eax),%edx
  8009d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009db:	8b 10                	mov    (%eax),%edx
  8009dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8009e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009e6:	eb 32                	jmp    800a1a <vprintfmt+0x308>
	else if (lflag)
  8009e8:	85 d2                	test   %edx,%edx
  8009ea:	74 18                	je     800a04 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8009ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ef:	8d 50 04             	lea    0x4(%eax),%edx
  8009f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f5:	8b 00                	mov    (%eax),%eax
  8009f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009fa:	89 c1                	mov    %eax,%ecx
  8009fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800a02:	eb 16                	jmp    800a1a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800a04:	8b 45 14             	mov    0x14(%ebp),%eax
  800a07:	8d 50 04             	lea    0x4(%eax),%edx
  800a0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0d:	8b 00                	mov    (%eax),%eax
  800a0f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a12:	89 c7                	mov    %eax,%edi
  800a14:	c1 ff 1f             	sar    $0x1f,%edi
  800a17:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a1d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a20:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a25:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a29:	79 7d                	jns    800aa8 <vprintfmt+0x396>
				putch('-', putdat);
  800a2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a36:	ff d6                	call   *%esi
				num = -(long long) num;
  800a38:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a3e:	f7 d8                	neg    %eax
  800a40:	83 d2 00             	adc    $0x0,%edx
  800a43:	f7 da                	neg    %edx
			}
			base = 10;
  800a45:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a4a:	eb 5c                	jmp    800aa8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4f:	e8 3f fc ff ff       	call   800693 <getuint>
			base = 10;
  800a54:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a59:	eb 4d                	jmp    800aa8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5e:	e8 30 fc ff ff       	call   800693 <getuint>
			base = 8;
  800a63:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a68:	eb 3e                	jmp    800aa8 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  800a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a75:	ff d6                	call   *%esi
			putch('x', putdat);
  800a77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a82:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 04             	lea    0x4(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a8d:	8b 00                	mov    (%eax),%eax
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a94:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a99:	eb 0d                	jmp    800aa8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a9b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9e:	e8 f0 fb ff ff       	call   800693 <getuint>
			base = 16;
  800aa3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800aac:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800ab0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ab3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ab7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac2:	89 da                	mov    %ebx,%edx
  800ac4:	89 f0                	mov    %esi,%eax
  800ac6:	e8 d5 fa ff ff       	call   8005a0 <printnum>
			break;
  800acb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ace:	e9 64 fc ff ff       	jmp    800737 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ad3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad7:	89 0c 24             	mov    %ecx,(%esp)
  800ada:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800adc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800adf:	e9 53 fc ff ff       	jmp    800737 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800af1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800af5:	0f 84 3c fc ff ff    	je     800737 <vprintfmt+0x25>
  800afb:	83 ef 01             	sub    $0x1,%edi
  800afe:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b02:	75 f7                	jne    800afb <vprintfmt+0x3e9>
  800b04:	e9 2e fc ff ff       	jmp    800737 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b09:	83 c4 4c             	add    $0x4c,%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	83 ec 28             	sub    $0x28,%esp
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b20:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b24:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2e:	85 d2                	test   %edx,%edx
  800b30:	7e 30                	jle    800b62 <vsnprintf+0x51>
  800b32:	85 c0                	test   %eax,%eax
  800b34:	74 2c                	je     800b62 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b44:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4b:	c7 04 24 cd 06 80 00 	movl   $0x8006cd,(%esp)
  800b52:	e8 bb fb ff ff       	call   800712 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b60:	eb 05                	jmp    800b67 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b6f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b76:	8b 45 10             	mov    0x10(%ebp),%eax
  800b79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	89 04 24             	mov    %eax,(%esp)
  800b8a:	e8 82 ff ff ff       	call   800b11 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    
  800b91:	66 90                	xchg   %ax,%ax
  800b93:	66 90                	xchg   %ax,%ax
  800b95:	66 90                	xchg   %ax,%ax
  800b97:	66 90                	xchg   %ax,%ax
  800b99:	66 90                	xchg   %ax,%ax
  800b9b:	66 90                	xchg   %ax,%ax
  800b9d:	66 90                	xchg   %ax,%ax
  800b9f:	90                   	nop

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	80 3a 00             	cmpb   $0x0,(%edx)
  800ba9:	74 10                	je     800bbb <strlen+0x1b>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb7:	75 f7                	jne    800bb0 <strlen+0x10>
  800bb9:	eb 05                	jmp    800bc0 <strlen+0x20>
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bcc:	85 c9                	test   %ecx,%ecx
  800bce:	74 1c                	je     800bec <strnlen+0x2a>
  800bd0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bd3:	74 1e                	je     800bf3 <strnlen+0x31>
  800bd5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bda:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bdc:	39 ca                	cmp    %ecx,%edx
  800bde:	74 18                	je     800bf8 <strnlen+0x36>
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800be8:	75 f0                	jne    800bda <strnlen+0x18>
  800bea:	eb 0c                	jmp    800bf8 <strnlen+0x36>
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	eb 05                	jmp    800bf8 <strnlen+0x36>
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c05:	89 c2                	mov    %eax,%edx
  800c07:	0f b6 19             	movzbl (%ecx),%ebx
  800c0a:	88 1a                	mov    %bl,(%edx)
  800c0c:	83 c2 01             	add    $0x1,%edx
  800c0f:	83 c1 01             	add    $0x1,%ecx
  800c12:	84 db                	test   %bl,%bl
  800c14:	75 f1                	jne    800c07 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c16:	5b                   	pop    %ebx
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 08             	sub    $0x8,%esp
  800c20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c23:	89 1c 24             	mov    %ebx,(%esp)
  800c26:	e8 75 ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c32:	01 d8                	add    %ebx,%eax
  800c34:	89 04 24             	mov    %eax,(%esp)
  800c37:	e8 bf ff ff ff       	call   800bfb <strcpy>
	return dst;
}
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	83 c4 08             	add    $0x8,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c52:	85 db                	test   %ebx,%ebx
  800c54:	74 16                	je     800c6c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800c56:	01 f3                	add    %esi,%ebx
  800c58:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800c5a:	0f b6 02             	movzbl (%edx),%eax
  800c5d:	88 01                	mov    %al,(%ecx)
  800c5f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c62:	80 3a 01             	cmpb   $0x1,(%edx)
  800c65:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c68:	39 d9                	cmp    %ebx,%ecx
  800c6a:	75 ee                	jne    800c5a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c81:	89 f8                	mov    %edi,%eax
  800c83:	85 f6                	test   %esi,%esi
  800c85:	74 33                	je     800cba <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800c87:	83 fe 01             	cmp    $0x1,%esi
  800c8a:	74 25                	je     800cb1 <strlcpy+0x3f>
  800c8c:	0f b6 0b             	movzbl (%ebx),%ecx
  800c8f:	84 c9                	test   %cl,%cl
  800c91:	74 22                	je     800cb5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c93:	83 ee 02             	sub    $0x2,%esi
  800c96:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c9b:	88 08                	mov    %cl,(%eax)
  800c9d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca0:	39 f2                	cmp    %esi,%edx
  800ca2:	74 13                	je     800cb7 <strlcpy+0x45>
  800ca4:	83 c2 01             	add    $0x1,%edx
  800ca7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cab:	84 c9                	test   %cl,%cl
  800cad:	75 ec                	jne    800c9b <strlcpy+0x29>
  800caf:	eb 06                	jmp    800cb7 <strlcpy+0x45>
  800cb1:	89 f8                	mov    %edi,%eax
  800cb3:	eb 02                	jmp    800cb7 <strlcpy+0x45>
  800cb5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cb7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cba:	29 f8                	sub    %edi,%eax
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cca:	0f b6 01             	movzbl (%ecx),%eax
  800ccd:	84 c0                	test   %al,%al
  800ccf:	74 15                	je     800ce6 <strcmp+0x25>
  800cd1:	3a 02                	cmp    (%edx),%al
  800cd3:	75 11                	jne    800ce6 <strcmp+0x25>
		p++, q++;
  800cd5:	83 c1 01             	add    $0x1,%ecx
  800cd8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cdb:	0f b6 01             	movzbl (%ecx),%eax
  800cde:	84 c0                	test   %al,%al
  800ce0:	74 04                	je     800ce6 <strcmp+0x25>
  800ce2:	3a 02                	cmp    (%edx),%al
  800ce4:	74 ef                	je     800cd5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce6:	0f b6 c0             	movzbl %al,%eax
  800ce9:	0f b6 12             	movzbl (%edx),%edx
  800cec:	29 d0                	sub    %edx,%eax
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800cfe:	85 f6                	test   %esi,%esi
  800d00:	74 29                	je     800d2b <strncmp+0x3b>
  800d02:	0f b6 03             	movzbl (%ebx),%eax
  800d05:	84 c0                	test   %al,%al
  800d07:	74 30                	je     800d39 <strncmp+0x49>
  800d09:	3a 02                	cmp    (%edx),%al
  800d0b:	75 2c                	jne    800d39 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800d0d:	8d 43 01             	lea    0x1(%ebx),%eax
  800d10:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800d12:	89 c3                	mov    %eax,%ebx
  800d14:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d17:	39 f0                	cmp    %esi,%eax
  800d19:	74 17                	je     800d32 <strncmp+0x42>
  800d1b:	0f b6 08             	movzbl (%eax),%ecx
  800d1e:	84 c9                	test   %cl,%cl
  800d20:	74 17                	je     800d39 <strncmp+0x49>
  800d22:	83 c0 01             	add    $0x1,%eax
  800d25:	3a 0a                	cmp    (%edx),%cl
  800d27:	74 e9                	je     800d12 <strncmp+0x22>
  800d29:	eb 0e                	jmp    800d39 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d30:	eb 0f                	jmp    800d41 <strncmp+0x51>
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 08                	jmp    800d41 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d39:	0f b6 03             	movzbl (%ebx),%eax
  800d3c:	0f b6 12             	movzbl (%edx),%edx
  800d3f:	29 d0                	sub    %edx,%eax
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	53                   	push   %ebx
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d4f:	0f b6 18             	movzbl (%eax),%ebx
  800d52:	84 db                	test   %bl,%bl
  800d54:	74 1d                	je     800d73 <strchr+0x2e>
  800d56:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d58:	38 d3                	cmp    %dl,%bl
  800d5a:	75 06                	jne    800d62 <strchr+0x1d>
  800d5c:	eb 1a                	jmp    800d78 <strchr+0x33>
  800d5e:	38 ca                	cmp    %cl,%dl
  800d60:	74 16                	je     800d78 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d62:	83 c0 01             	add    $0x1,%eax
  800d65:	0f b6 10             	movzbl (%eax),%edx
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	75 f2                	jne    800d5e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 05                	jmp    800d78 <strchr+0x33>
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	53                   	push   %ebx
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d85:	0f b6 18             	movzbl (%eax),%ebx
  800d88:	84 db                	test   %bl,%bl
  800d8a:	74 16                	je     800da2 <strfind+0x27>
  800d8c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d8e:	38 d3                	cmp    %dl,%bl
  800d90:	75 06                	jne    800d98 <strfind+0x1d>
  800d92:	eb 0e                	jmp    800da2 <strfind+0x27>
  800d94:	38 ca                	cmp    %cl,%dl
  800d96:	74 0a                	je     800da2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d98:	83 c0 01             	add    $0x1,%eax
  800d9b:	0f b6 10             	movzbl (%eax),%edx
  800d9e:	84 d2                	test   %dl,%dl
  800da0:	75 f2                	jne    800d94 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800da2:	5b                   	pop    %ebx
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800db4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dba:	85 c9                	test   %ecx,%ecx
  800dbc:	74 36                	je     800df4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc4:	75 28                	jne    800dee <memset+0x49>
  800dc6:	f6 c1 03             	test   $0x3,%cl
  800dc9:	75 23                	jne    800dee <memset+0x49>
		c &= 0xFF;
  800dcb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dcf:	89 d3                	mov    %edx,%ebx
  800dd1:	c1 e3 08             	shl    $0x8,%ebx
  800dd4:	89 d6                	mov    %edx,%esi
  800dd6:	c1 e6 18             	shl    $0x18,%esi
  800dd9:	89 d0                	mov    %edx,%eax
  800ddb:	c1 e0 10             	shl    $0x10,%eax
  800dde:	09 f0                	or     %esi,%eax
  800de0:	09 c2                	or     %eax,%edx
  800de2:	89 d0                	mov    %edx,%eax
  800de4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800de6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800de9:	fc                   	cld    
  800dea:	f3 ab                	rep stos %eax,%es:(%edi)
  800dec:	eb 06                	jmp    800df4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	fc                   	cld    
  800df2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800df4:	89 f8                	mov    %edi,%eax
  800df6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dff:	89 ec                	mov    %ebp,%esp
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	83 ec 08             	sub    $0x8,%esp
  800e09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e18:	39 c6                	cmp    %eax,%esi
  800e1a:	73 36                	jae    800e52 <memmove+0x4f>
  800e1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e1f:	39 d0                	cmp    %edx,%eax
  800e21:	73 2f                	jae    800e52 <memmove+0x4f>
		s += n;
		d += n;
  800e23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	f6 c2 03             	test   $0x3,%dl
  800e29:	75 1b                	jne    800e46 <memmove+0x43>
  800e2b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e31:	75 13                	jne    800e46 <memmove+0x43>
  800e33:	f6 c1 03             	test   $0x3,%cl
  800e36:	75 0e                	jne    800e46 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e38:	83 ef 04             	sub    $0x4,%edi
  800e3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e3e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e41:	fd                   	std    
  800e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e44:	eb 09                	jmp    800e4f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e46:	83 ef 01             	sub    $0x1,%edi
  800e49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e4c:	fd                   	std    
  800e4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e4f:	fc                   	cld    
  800e50:	eb 20                	jmp    800e72 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e58:	75 13                	jne    800e6d <memmove+0x6a>
  800e5a:	a8 03                	test   $0x3,%al
  800e5c:	75 0f                	jne    800e6d <memmove+0x6a>
  800e5e:	f6 c1 03             	test   $0x3,%cl
  800e61:	75 0a                	jne    800e6d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e66:	89 c7                	mov    %eax,%edi
  800e68:	fc                   	cld    
  800e69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e6b:	eb 05                	jmp    800e72 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e6d:	89 c7                	mov    %eax,%edi
  800e6f:	fc                   	cld    
  800e70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e82:	8b 45 10             	mov    0x10(%ebp),%eax
  800e85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 68 ff ff ff       	call   800e03 <memmove>
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ea6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eac:	8d 78 ff             	lea    -0x1(%eax),%edi
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	74 36                	je     800ee9 <memcmp+0x4c>
		if (*s1 != *s2)
  800eb3:	0f b6 03             	movzbl (%ebx),%eax
  800eb6:	0f b6 0e             	movzbl (%esi),%ecx
  800eb9:	38 c8                	cmp    %cl,%al
  800ebb:	75 17                	jne    800ed4 <memcmp+0x37>
  800ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec2:	eb 1a                	jmp    800ede <memcmp+0x41>
  800ec4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ec9:	83 c2 01             	add    $0x1,%edx
  800ecc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ed0:	38 c8                	cmp    %cl,%al
  800ed2:	74 0a                	je     800ede <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ed4:	0f b6 c0             	movzbl %al,%eax
  800ed7:	0f b6 c9             	movzbl %cl,%ecx
  800eda:	29 c8                	sub    %ecx,%eax
  800edc:	eb 10                	jmp    800eee <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ede:	39 fa                	cmp    %edi,%edx
  800ee0:	75 e2                	jne    800ec4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	eb 05                	jmp    800eee <memcmp+0x51>
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	53                   	push   %ebx
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800efd:	89 c2                	mov    %eax,%edx
  800eff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f02:	39 d0                	cmp    %edx,%eax
  800f04:	73 13                	jae    800f19 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f06:	89 d9                	mov    %ebx,%ecx
  800f08:	38 18                	cmp    %bl,(%eax)
  800f0a:	75 06                	jne    800f12 <memfind+0x1f>
  800f0c:	eb 0b                	jmp    800f19 <memfind+0x26>
  800f0e:	38 08                	cmp    %cl,(%eax)
  800f10:	74 07                	je     800f19 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f12:	83 c0 01             	add    $0x1,%eax
  800f15:	39 d0                	cmp    %edx,%eax
  800f17:	75 f5                	jne    800f0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2b:	0f b6 02             	movzbl (%edx),%eax
  800f2e:	3c 09                	cmp    $0x9,%al
  800f30:	74 04                	je     800f36 <strtol+0x1a>
  800f32:	3c 20                	cmp    $0x20,%al
  800f34:	75 0e                	jne    800f44 <strtol+0x28>
		s++;
  800f36:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f39:	0f b6 02             	movzbl (%edx),%eax
  800f3c:	3c 09                	cmp    $0x9,%al
  800f3e:	74 f6                	je     800f36 <strtol+0x1a>
  800f40:	3c 20                	cmp    $0x20,%al
  800f42:	74 f2                	je     800f36 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f44:	3c 2b                	cmp    $0x2b,%al
  800f46:	75 0a                	jne    800f52 <strtol+0x36>
		s++;
  800f48:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f50:	eb 10                	jmp    800f62 <strtol+0x46>
  800f52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f57:	3c 2d                	cmp    $0x2d,%al
  800f59:	75 07                	jne    800f62 <strtol+0x46>
		s++, neg = 1;
  800f5b:	83 c2 01             	add    $0x1,%edx
  800f5e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f68:	75 15                	jne    800f7f <strtol+0x63>
  800f6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800f6d:	75 10                	jne    800f7f <strtol+0x63>
  800f6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f73:	75 0a                	jne    800f7f <strtol+0x63>
		s += 2, base = 16;
  800f75:	83 c2 02             	add    $0x2,%edx
  800f78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f7d:	eb 10                	jmp    800f8f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f7f:	85 db                	test   %ebx,%ebx
  800f81:	75 0c                	jne    800f8f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f83:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f85:	80 3a 30             	cmpb   $0x30,(%edx)
  800f88:	75 05                	jne    800f8f <strtol+0x73>
		s++, base = 8;
  800f8a:	83 c2 01             	add    $0x1,%edx
  800f8d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f97:	0f b6 0a             	movzbl (%edx),%ecx
  800f9a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f9d:	89 f3                	mov    %esi,%ebx
  800f9f:	80 fb 09             	cmp    $0x9,%bl
  800fa2:	77 08                	ja     800fac <strtol+0x90>
			dig = *s - '0';
  800fa4:	0f be c9             	movsbl %cl,%ecx
  800fa7:	83 e9 30             	sub    $0x30,%ecx
  800faa:	eb 22                	jmp    800fce <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800fac:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800faf:	89 f3                	mov    %esi,%ebx
  800fb1:	80 fb 19             	cmp    $0x19,%bl
  800fb4:	77 08                	ja     800fbe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800fb6:	0f be c9             	movsbl %cl,%ecx
  800fb9:	83 e9 57             	sub    $0x57,%ecx
  800fbc:	eb 10                	jmp    800fce <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800fbe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fc1:	89 f3                	mov    %esi,%ebx
  800fc3:	80 fb 19             	cmp    $0x19,%bl
  800fc6:	77 16                	ja     800fde <strtol+0xc2>
			dig = *s - 'A' + 10;
  800fc8:	0f be c9             	movsbl %cl,%ecx
  800fcb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fce:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800fd1:	7d 0f                	jge    800fe2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800fd3:	83 c2 01             	add    $0x1,%edx
  800fd6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800fda:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800fdc:	eb b9                	jmp    800f97 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800fde:	89 c1                	mov    %eax,%ecx
  800fe0:	eb 02                	jmp    800fe4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fe2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fe4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fe8:	74 05                	je     800fef <strtol+0xd3>
		*endptr = (char *) s;
  800fea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fed:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fef:	89 ca                	mov    %ecx,%edx
  800ff1:	f7 da                	neg    %edx
  800ff3:	85 ff                	test   %edi,%edi
  800ff5:	0f 45 c2             	cmovne %edx,%eax
}
  800ff8:	83 c4 04             	add    $0x4,%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801006:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80100d:	75 60                	jne    80106f <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  80100f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801016:	00 
  801017:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80101e:	ee 
  80101f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801026:	e8 bd f1 ff ff       	call   8001e8 <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 2c                	jns    80105b <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  80102f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801033:	c7 04 24 04 16 80 00 	movl   $0x801604,(%esp)
  80103a:	e8 44 f5 ff ff       	call   800583 <cprintf>
			panic("Something wrong with allocation of user exception"
  80103f:	c7 44 24 08 18 16 80 	movl   $0x801618,0x8(%esp)
  801046:	00 
  801047:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80104e:	00 
  80104f:	c7 04 24 08 16 80 00 	movl   $0x801608,(%esp)
  801056:	e8 2d f4 ff ff       	call   800488 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80105b:	c7 44 24 04 50 04 80 	movl   $0x800450,0x4(%esp)
  801062:	00 
  801063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106a:	e8 f2 f2 ff ff       	call   800361 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    
  801079:	66 90                	xchg   %ax,%ax
  80107b:	66 90                	xchg   %ax,%ax
  80107d:	66 90                	xchg   %ax,%ax
  80107f:	90                   	nop

00801080 <__udivdi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801087:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80108b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80108f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801093:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801097:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010a5:	89 ea                	mov    %ebp,%edx
  8010a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010ab:	75 33                	jne    8010e0 <__udivdi3+0x60>
  8010ad:	39 e9                	cmp    %ebp,%ecx
  8010af:	77 6f                	ja     801120 <__udivdi3+0xa0>
  8010b1:	85 c9                	test   %ecx,%ecx
  8010b3:	89 ce                	mov    %ecx,%esi
  8010b5:	75 0b                	jne    8010c2 <__udivdi3+0x42>
  8010b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bc:	31 d2                	xor    %edx,%edx
  8010be:	f7 f1                	div    %ecx
  8010c0:	89 c6                	mov    %eax,%esi
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	89 e8                	mov    %ebp,%eax
  8010c6:	f7 f6                	div    %esi
  8010c8:	89 c5                	mov    %eax,%ebp
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	f7 f6                	div    %esi
  8010ce:	89 ea                	mov    %ebp,%edx
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	39 e8                	cmp    %ebp,%eax
  8010e2:	77 24                	ja     801108 <__udivdi3+0x88>
  8010e4:	0f bd c8             	bsr    %eax,%ecx
  8010e7:	83 f1 1f             	xor    $0x1f,%ecx
  8010ea:	89 0c 24             	mov    %ecx,(%esp)
  8010ed:	75 49                	jne    801138 <__udivdi3+0xb8>
  8010ef:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010f3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8010f7:	0f 86 ab 00 00 00    	jbe    8011a8 <__udivdi3+0x128>
  8010fd:	39 e8                	cmp    %ebp,%eax
  8010ff:	0f 82 a3 00 00 00    	jb     8011a8 <__udivdi3+0x128>
  801105:	8d 76 00             	lea    0x0(%esi),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	31 c0                	xor    %eax,%eax
  80110c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801110:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801114:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801118:	83 c4 1c             	add    $0x1c,%esp
  80111b:	c3                   	ret    
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f8                	mov    %edi,%eax
  801122:	f7 f1                	div    %ecx
  801124:	31 d2                	xor    %edx,%edx
  801126:	8b 74 24 10          	mov    0x10(%esp),%esi
  80112a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801132:	83 c4 1c             	add    $0x1c,%esp
  801135:	c3                   	ret    
  801136:	66 90                	xchg   %ax,%ax
  801138:	0f b6 0c 24          	movzbl (%esp),%ecx
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	b8 20 00 00 00       	mov    $0x20,%eax
  801143:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801147:	2b 04 24             	sub    (%esp),%eax
  80114a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80114e:	d3 e6                	shl    %cl,%esi
  801150:	89 c1                	mov    %eax,%ecx
  801152:	d3 ed                	shr    %cl,%ebp
  801154:	0f b6 0c 24          	movzbl (%esp),%ecx
  801158:	09 f5                	or     %esi,%ebp
  80115a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80115e:	d3 e6                	shl    %cl,%esi
  801160:	89 c1                	mov    %eax,%ecx
  801162:	89 74 24 04          	mov    %esi,0x4(%esp)
  801166:	89 d6                	mov    %edx,%esi
  801168:	d3 ee                	shr    %cl,%esi
  80116a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80116e:	d3 e2                	shl    %cl,%edx
  801170:	89 c1                	mov    %eax,%ecx
  801172:	d3 ef                	shr    %cl,%edi
  801174:	09 d7                	or     %edx,%edi
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	f7 f5                	div    %ebp
  80117c:	89 d6                	mov    %edx,%esi
  80117e:	89 c7                	mov    %eax,%edi
  801180:	f7 64 24 04          	mull   0x4(%esp)
  801184:	39 d6                	cmp    %edx,%esi
  801186:	72 30                	jb     8011b8 <__udivdi3+0x138>
  801188:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80118c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801190:	d3 e5                	shl    %cl,%ebp
  801192:	39 c5                	cmp    %eax,%ebp
  801194:	73 04                	jae    80119a <__udivdi3+0x11a>
  801196:	39 d6                	cmp    %edx,%esi
  801198:	74 1e                	je     8011b8 <__udivdi3+0x138>
  80119a:	89 f8                	mov    %edi,%eax
  80119c:	31 d2                	xor    %edx,%edx
  80119e:	e9 69 ff ff ff       	jmp    80110c <__udivdi3+0x8c>
  8011a3:	90                   	nop
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	31 d2                	xor    %edx,%edx
  8011aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8011af:	e9 58 ff ff ff       	jmp    80110c <__udivdi3+0x8c>
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c9:	83 c4 1c             	add    $0x1c,%esp
  8011cc:	c3                   	ret    
  8011cd:	66 90                	xchg   %ax,%ax
  8011cf:	90                   	nop

008011d0 <__umoddi3>:
  8011d0:	83 ec 2c             	sub    $0x2c,%esp
  8011d3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011d7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011db:	89 74 24 20          	mov    %esi,0x20(%esp)
  8011df:	8b 74 24 38          	mov    0x38(%esp),%esi
  8011e3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8011e7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8011f3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8011f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011ff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801203:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801207:	75 1f                	jne    801228 <__umoddi3+0x58>
  801209:	39 fe                	cmp    %edi,%esi
  80120b:	76 63                	jbe    801270 <__umoddi3+0xa0>
  80120d:	89 c8                	mov    %ecx,%eax
  80120f:	89 fa                	mov    %edi,%edx
  801211:	f7 f6                	div    %esi
  801213:	89 d0                	mov    %edx,%eax
  801215:	31 d2                	xor    %edx,%edx
  801217:	8b 74 24 20          	mov    0x20(%esp),%esi
  80121b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80121f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801223:	83 c4 2c             	add    $0x2c,%esp
  801226:	c3                   	ret    
  801227:	90                   	nop
  801228:	39 f8                	cmp    %edi,%eax
  80122a:	77 64                	ja     801290 <__umoddi3+0xc0>
  80122c:	0f bd e8             	bsr    %eax,%ebp
  80122f:	83 f5 1f             	xor    $0x1f,%ebp
  801232:	75 74                	jne    8012a8 <__umoddi3+0xd8>
  801234:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801238:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80123c:	0f 87 0e 01 00 00    	ja     801350 <__umoddi3+0x180>
  801242:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801246:	29 f1                	sub    %esi,%ecx
  801248:	19 c7                	sbb    %eax,%edi
  80124a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80124e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801252:	8b 44 24 14          	mov    0x14(%esp),%eax
  801256:	8b 54 24 18          	mov    0x18(%esp),%edx
  80125a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80125e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801262:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801266:	83 c4 2c             	add    $0x2c,%esp
  801269:	c3                   	ret    
  80126a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801270:	85 f6                	test   %esi,%esi
  801272:	89 f5                	mov    %esi,%ebp
  801274:	75 0b                	jne    801281 <__umoddi3+0xb1>
  801276:	b8 01 00 00 00       	mov    $0x1,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	f7 f6                	div    %esi
  80127f:	89 c5                	mov    %eax,%ebp
  801281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801285:	31 d2                	xor    %edx,%edx
  801287:	f7 f5                	div    %ebp
  801289:	89 c8                	mov    %ecx,%eax
  80128b:	f7 f5                	div    %ebp
  80128d:	eb 84                	jmp    801213 <__umoddi3+0x43>
  80128f:	90                   	nop
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 fa                	mov    %edi,%edx
  801294:	8b 74 24 20          	mov    0x20(%esp),%esi
  801298:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80129c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012a0:	83 c4 2c             	add    $0x2c,%esp
  8012a3:	c3                   	ret    
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012ac:	be 20 00 00 00       	mov    $0x20,%esi
  8012b1:	89 e9                	mov    %ebp,%ecx
  8012b3:	29 ee                	sub    %ebp,%esi
  8012b5:	d3 e2                	shl    %cl,%edx
  8012b7:	89 f1                	mov    %esi,%ecx
  8012b9:	d3 e8                	shr    %cl,%eax
  8012bb:	89 e9                	mov    %ebp,%ecx
  8012bd:	09 d0                	or     %edx,%eax
  8012bf:	89 fa                	mov    %edi,%edx
  8012c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012c9:	d3 e0                	shl    %cl,%eax
  8012cb:	89 f1                	mov    %esi,%ecx
  8012cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012d5:	d3 ea                	shr    %cl,%edx
  8012d7:	89 e9                	mov    %ebp,%ecx
  8012d9:	d3 e7                	shl    %cl,%edi
  8012db:	89 f1                	mov    %esi,%ecx
  8012dd:	d3 e8                	shr    %cl,%eax
  8012df:	89 e9                	mov    %ebp,%ecx
  8012e1:	09 f8                	or     %edi,%eax
  8012e3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012e7:	f7 74 24 0c          	divl   0xc(%esp)
  8012eb:	d3 e7                	shl    %cl,%edi
  8012ed:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012f1:	89 d7                	mov    %edx,%edi
  8012f3:	f7 64 24 10          	mull   0x10(%esp)
  8012f7:	39 d7                	cmp    %edx,%edi
  8012f9:	89 c1                	mov    %eax,%ecx
  8012fb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8012ff:	72 3b                	jb     80133c <__umoddi3+0x16c>
  801301:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801305:	72 31                	jb     801338 <__umoddi3+0x168>
  801307:	8b 44 24 18          	mov    0x18(%esp),%eax
  80130b:	29 c8                	sub    %ecx,%eax
  80130d:	19 d7                	sbb    %edx,%edi
  80130f:	89 e9                	mov    %ebp,%ecx
  801311:	89 fa                	mov    %edi,%edx
  801313:	d3 e8                	shr    %cl,%eax
  801315:	89 f1                	mov    %esi,%ecx
  801317:	d3 e2                	shl    %cl,%edx
  801319:	89 e9                	mov    %ebp,%ecx
  80131b:	09 d0                	or     %edx,%eax
  80131d:	89 fa                	mov    %edi,%edx
  80131f:	d3 ea                	shr    %cl,%edx
  801321:	8b 74 24 20          	mov    0x20(%esp),%esi
  801325:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801329:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80132d:	83 c4 2c             	add    $0x2c,%esp
  801330:	c3                   	ret    
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 d7                	cmp    %edx,%edi
  80133a:	75 cb                	jne    801307 <__umoddi3+0x137>
  80133c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801340:	89 c1                	mov    %eax,%ecx
  801342:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801346:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80134a:	eb bb                	jmp    801307 <__umoddi3+0x137>
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801354:	0f 82 e8 fe ff ff    	jb     801242 <__umoddi3+0x72>
  80135a:	e9 f3 fe ff ff       	jmp    801252 <__umoddi3+0x82>
