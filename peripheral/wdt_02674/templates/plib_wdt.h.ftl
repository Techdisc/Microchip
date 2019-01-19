/*******************************************************************************
  Interface definition of WDT PLIB.

  Company:
    Microchip Technology Inc.

  File Name:
    plib_wdt.h

  Summary:
    Interface definition of the Watch Dog Timer Plib (WDT).

  Description:
    This file defines the interface for the WDT Plib.
    It allows user to setup timeout duration and restart watch dog timer.
*******************************************************************************/

/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/

#ifndef ${WDT_INSTANCE_NAME}_H    // Guards against multiple inclusion
#define ${WDT_INSTANCE_NAME}_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus // Provide C++ Compatibility
 extern "C" {
#endif
<#--

// *****************************************************************************
// *****************************************************************************
// Section: Interface
// *****************************************************************************
// *****************************************************************************

<#if wdtinterruptMode == true>
	<#lt>typedef void (*WDT_CALLBACK)(uintptr_t context);
</#if>

<#if wdtinterruptMode == true>
	<#lt>typedef struct
	<#lt>{
	<#lt>	WDT_CALLBACK          callback; 
	<#lt>	uintptr_t               context;
	<#lt>} WDT_OBJECT ;
</#if>

/***************************** WDT API *******************************/
void ${WDT_INSTANCE_NAME}_Initialize( void );
void ${WDT_INSTANCE_NAME}_Clear( void );
<#if wdtinterruptMode == true>
	<#lt>void ${WDT_INSTANCE_NAME}_CallbackRegister( WDT_CALLBACK callback, uintptr_t context );
</#if>	

-->	
#ifdef __cplusplus // Provide C++ Compatibility
 }
#endif

#endif 
