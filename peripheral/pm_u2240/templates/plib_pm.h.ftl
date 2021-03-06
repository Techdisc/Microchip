/*******************************************************************************
  Power Manager(${PM_INSTANCE_NAME}) PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${PM_INSTANCE_NAME?lower_case}.h

  Summary
    ${PM_INSTANCE_NAME} PLIB Header File.

  Description
    This file defines the interface to the PM peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
// DOM-IGNORE-END

#ifndef PLIB_${PM_INSTANCE_NAME}_H    // Guards against multiple inclusion
#define PLIB_${PM_INSTANCE_NAME}_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
/* This section lists the other files that are included in this file.
*/

#include <stdbool.h>
#include <stddef.h>

// DOM-IGNORE-BEGIN
#ifdef __cplusplus // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************
<#if __TRUSTZONE_ENABLED?? &&  __TRUSTZONE_ENABLED == "true" && core.PM_IS_NON_SECURE >
<#else>
void ${PM_INSTANCE_NAME}_Initialize( void );
</#if>
void ${PM_INSTANCE_NAME}_IdleModeEnter( void );

void ${PM_INSTANCE_NAME}_StandbyModeEnter( void );

<#if HAS_BACKUP_SLEEP??>
void ${PM_INSTANCE_NAME}_BackupModeEnter( void );

</#if>
<#if HAS_OFF_SLEEP??>
void ${PM_INSTANCE_NAME}_OffModeEnter( void );

</#if>
<#if HAS_IORET_BIT??>
void ${PM_INSTANCE_NAME}_IO_RetentionSet( void );

void ${PM_INSTANCE_NAME}_IO_RetentionClear( void );
</#if>
<#if HAS_PLCFG??>
typedef enum
{
    PLCFG_PLSEL0 = PM_PLCFG_PLSEL_PL0,
    PLCFG_PLSEL2 = PM_PLCFG_PLSEL_PL2
}PLCFG_PLSEL;

bool ${PM_INSTANCE_NAME}_ConfigurePerformanceLevel(PLCFG_PLSEL plsel);

</#if>
// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END

#endif /* PLIB_${PM_INSTANCE_NAME}_H */
