
.data                    # Êý¾Ý¶ÎÉùÃ÷ 


             .extern  OSIntExit
             .extern  OSIntEnter
             .extern  OSTimeTick
             .extern  OSTaskSwHook

             .extern  OSIntNesting
             .extern  OSTickDOSCtr
             .extern  OSPrioHighRdy
             .extern  OSPrioCur
             .extern  OSRunning
             .extern  OSTCBCur
             .extern  OSTCBHighRdy

.text  
.code32

.globl  OSStartHighRdy
                 
              
OSStartHighRdy:   


		call	OSTaskSwHook

		incl	OSRunning

//Load the processor stack pointer with OSTCBHighRdy->OSTCBStkPtr

		mov OSTCBHighRdy, %eax	//Point to TCB of highest priority task ready to run
		mov  (%eax), %esp			//ESP = OSTCBHighRdy->OSTCBStkPtr

//Pop all the processor registers from the stack

		popa

//Execute a Return from interrupt intruction;

		iret


.globl OSCtxSw
        
OSCtxSw:

	// PUSH processor registers onto the current task's stack

		pusha

	//Save the stack pointer into OSTCBCur->OSTCBStkPtr

		mov	OSTCBCur, %eax
		mov	%esp,(%eax)			//Stack pointer is ESP

	// Call OSTaskSwHook();

		call	OSTaskSwHook

	//OSPrioCur = OSPrioHighRdy

		mov	OSPrioHighRdy, %al     //AL is OSPrioHighRdy
		mov	%al, OSPrioCur

	//OSTCBCur = OSTCBHighRdy

		mov OSTCBHighRdy, %eax		//EAX is OSTCBHighRdy
		mov	%eax,OSTCBCur

	//Load the processor stack pointer with OSTCBHighRdy->OSTCBStkPtr
	//Note that EAX is still OSTCBHighRdy.

		mov	(%eax), %esp			//ESP = OSTCBHighRdy->OSTCBStkPtr

	//Pop all the processor registers from the stack

		popa

	//Execute a Return from interrupt intruction;

		iret
// ******************************************************************************************************           
//                PERFORM A CONTEXT SWITCH (From an ISR)
//                         void OSIntCtxSw(void)
                         
                       
.globl  OSIntCtxSw

OSIntCtxSw:

 

	//Adjust the stack pointer to remove call to OsIntExit(), locals in 
	//OsIntExit() and the call to OSIntCtxSw();

	 
	  add	$24, %esp			//Ignore calls to OSIntExit, PUSHFD and OSIntCtxSw


	//Save the stack pointer into OSTCBCur->OSTCBStkPtr

		mov	OSTCBCur, %eax
		mov	%esp, (%eax)			//Stack pointer is ESP

	//Call OSTaskSwHook();

		call	OSTaskSwHook
		//OSPrioCur = OSPrioHighRdy

		mov	OSPrioHighRdy, %al     //AL is OSPrioHighRdy
		mov	%al, OSPrioCur

	//OSTCBCur = OSTCBHighRdy

		mov OSTCBHighRdy, %eax		//EAX is OSTCBHighRdy
		mov	%eax,OSTCBCur

	//Load the processor stack pointer with OSTCBHighRdy->OSTCBStkPtr
	//Note that EAX is still OSTCBHighRdy.

		mov	(%eax), %esp			//ESP = OSTCBHighRdy->OSTCBStkPtr

	//Pop all the processor registers from the stack

		popa

	//Execute a Return from interrupt intruction;

		iret

// ******************************************************************************************************

.globl DefIntHandler

DefIntHandler:
		iret


.globl  OSTickISR	

OSTickISR: 

		pusha                                # Save interrupted task s context

		mov $0x20, %al
		out %al, $0x20

		call OSIntEnter
		call OSTimeTick
		call OSIntExit
				
		popa
		
		iret
.end
   
