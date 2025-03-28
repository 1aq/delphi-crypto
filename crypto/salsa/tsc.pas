unit TSC;

{Access to Time Stamp Counter (RDTSC)}

interface

{$i STD.INC}

(*************************************************************************

 DESCRIPTION     :  Access to Time Stamp Counter (RDTSC)
                    General counter: TSC if present and _HasRDTSC is true,
                    GetTickCount or SysTick otherwise for Windows/DOS,
                    milliseconds since midnight on non-Windows 32 bit systems

 REQUIREMENTS    :  TP5-7, D1-D7/D9-D10, FPC, VP

 EXTERNAL DATA   :  _tsc.obj for 16 bit compilers

 MEMORY USAGE    :  ---

 DISPLAY MODE    :  ---

 REFERENCES      :  ---


 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.10     06.12.03  W.Ehrhardt  Initial version from old hrtimer
 0.20     06.12.03  we          with _HasRDTSC: boolean
 0.30     06.12.03  we          with _ReadCounter
 0.31     06.12.03  we          $J+ f�r D4Plus
 0.32     17.12.03  we          interface _check.. routines
 0.33     02.01.04  we          Second cpuid after RDTSC
 0.34     11.04.04  we          Delphi 7
 0.35     28.03.08  we          _ReadCounter via sysutils.time on non-Windows 32 bit systems
**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2002-2008 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

type
  TCtrRec = packed record
             LDW, HDW: longint;
           end;                  {64 bit TSC counter record}

var
  _HasRDTSC: boolean;  {will be true if RDTSC instruction is supported}

procedure _ReadTSC(var Ctr: TCtrRec);
  {-Read Time Stamp Counter}

procedure _ReadCounter(var Ctr: TCtrRec);
  {-Read TSC if present, else GetTickCount/SysTick/milliseconds since midnight}

function  _CheckCPUID: boolean;
  {-check if CPUID supported}

function  _CheckRDTSC: boolean;
  {-check if RDTSC supported, check CPUID first!!}


implementation


{$ifdef BIT32}
  {$ifdef WIN32}
    uses windows;
  {$else}
    uses sysutils;
  {$endif}
{$endif}


{$ifdef BIT32}

{---------------------------------------------------------------------------}
function _CheckCPUID: boolean; assembler;
  {-check if CPUID supported}
asm
  pushfd
  pushfd
  pop      eax
  mov      ecx,eax
  xor      eax,$200000
  push     eax
  popfd
  pushfd
  pop      eax
  popfd
  xor      eax,ecx
  setnz    al
end;

{---------------------------------------------------------------------------}
function _CheckRDTSC: boolean; assembler;
  {-check if RDTSC supported, check CPUID first!!}
asm
  push   ebx
  mov    eax,1
  db     $0f,$a2          {cpuid}
  test   dx,$10           {test RDTSC flag in Features}
  setnz  al
  pop    ebx
end;


{---------------------------------------------------------------------------}
procedure _RDTSC(var Ctr: TCtrRec);
  {-Read Time Stamp Counter}
begin
  asm
    push  ebx
    xor   eax, eax
    xor   ebx, ebx
    xor   ecx, ecx
    xor   edx, edx
    db    $0f,$a2    {cpuid}
    db    $0f,$31    {rdtsc}
    mov   ecx,[Ctr]
    mov   [ecx],eax
    mov   [ecx+4],edx
    xor   eax, eax
    db    $0f,$a2    {cpuid}
    pop   ebx
  end;
end;

{$else}

{$f+}

function  _CheckCPUID: boolean; external;
  {-check if CPUID supported}

function  _CheckRDTSC: boolean; external;
  {-check if RDTSC supported, check CPUID first!!}

procedure _RDTSC(var Ctr: TCtrRec); external;
  {-Read Time Stamp Counter}
{$l _tsc}

{$endif}


{---------------------------------------------------------------------------}
procedure _ReadTSC(var Ctr: TCtrRec);
  {-Read Time Stamp Counter}
begin
  if _HasRDTSC then _RDTSC(Ctr) else fillchar(Ctr, sizeof(Ctr),0);
end;


{---------------------------------------------------------------------------}
procedure _ReadCounter(var Ctr: TCtrRec);
  {-Read TSC if present, else GetTickCount/SysTick/milliseconds since midnight}
begin
  if _HasRDTSC then _RDTSC(Ctr)
  else begin
    Ctr.HDW := 0;
    {$ifdef WIN32}
      Ctr.LDW := GetTickCount;
    {$else}
      {$ifdef BIT16}
        {$ifdef DPMI}
          Ctr.LDW := MemL[Seg0040:$6c];
        {$else}
          Ctr.LDW := MemL[$40:$6c];
        {$endif}
      {$else}
         {Return milliseconds since midnight on non-Windows 32Bit systems }
         {Thanks to Giorgio Tani for reporting the problem that MemL is   }
         {not defined on BSD and Linux systems with FPC/Lazarus. Note that}
         {FPC for DOS target now also uses this conditional branch.       }
         {$ifdef debug}
           {$ifdef HAS_MSG}
             {$message '_ReadCounter via sysutils.time'}
           {$endif}
         {$endif}
         Ctr.LDW := round(86400000*time);
      {$endif}
    {$endif}
  end;
end;


begin
  if _CheckCPUID then _HasRDTSC := _CheckRDTSC
  else _HasRDTSC := false;
end.
