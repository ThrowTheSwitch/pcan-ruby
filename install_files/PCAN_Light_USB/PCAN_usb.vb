' Pcan_usb.vb
'
' !! VB.net Declarations for PCAN-Light Driver USB Version !!
' (c) 2002 PEAK-System Technik GmbH
' Rev. 1.0
' 16.09.2002
'
' This software is NO freeware.
' You are only permitted to use this software if you have hardware from
' PEAK-System Technik GmbH.
'
' Do not use the software or parts from it to communicate with non PEAK-Software.
'
' If you like a more performant and powerful device driver, take a look at the
' PCAN-Tools which allow:
' - full buffered send/transmit by driver (up to 512 CAN-Msg )
' - timer resolution 1 µs
' - callback function for receive
' - define message filter for application
' - write one software for all hardware ( no recompile )
' - communication between every hard & software
' - powerful development tools (monitor, logger etc.

Imports System
Imports System.Text
Imports System.Runtime.InteropServices

Public Class PCAN_usb

#Region "Frames, ID's und CAN message types"

    ' Initialization constants - Frames
    Public Const CAN_INIT_TYPE_EX As Integer = 1 ' Extended Frames
    Public Const CAN_INIT_TYPE_ST As Integer = 0 ' Standard Frames

    'Initialisation constants - ID
    Public Const CAN_MAX_STANDARD_ID As Integer = &H7FF
    Public Const CAN_MAX_EXTENDED_ID As Integer = &H1FFFFFFF

    ' CAN message types
    Public Const MSGTYPE_STANDARD As Integer = &H0  ' Standard Frame (11 bit ID)() As 0x00
    Public Const MSGTYPE_RTR As Integer = &H1       ' 1, if remote request, if 0 a data msg() As 0x01
    Public Const MSGTYPE_EXTENDED As Integer = &H2  ' 1, if CAN 2.0B Frame (29 bit ID)() As 0x02
    Public Const MSGTYPE_STATUS As Integer = &H80   ' 1, if msg is a status msg() As 0x80
#End Region

#Region "Baudrate Codes"
    ' BTR0BTR1 register
    ' Baudrate code = register value BTR0/BTR1
    Public Const CAN_BAUD_1M As Integer = &H14      '   1 MBit/sec
    Public Const CAN_BAUD_500K As Integer = &H1C    ' 500 KBit/sec
    Public Const CAN_BAUD_250K As Integer = &H11C   ' 250 KBit/sec
    Public Const CAN_BAUD_125K As Integer = &H31C   ' 125 KBit/sec
    Public Const CAN_BAUD_100K As Integer = &H432F  ' 100 KBit/sec 
    Public Const CAN_BAUD_50K As Integer = &H472F   '  50 KBit/sec
    Public Const CAN_BAUD_20K As Integer = &H532F   '  20 KBit/sec
    Public Const CAN_BAUD_10K As Integer = &H672F   '  10 KBit/sec
    Public Const CAN_BAUD_5K As Integer = &H7F7F    '   5 KBit/sec

    ' You can define your own Baudrate for the BTROBTR1 register.
    ' Take a look at www.peak-system.com for our software BAUDTOOL to
    ' calculate the BTROBTR1 register for every baudrate and sample point.
#End Region

#Region "Error Codes"
    ' Error codes (bit code)
    Public Const CAN_ERR_OK As Integer = &H0               ' No error
    Public Const CAN_ERR_XMTFULL As Integer = &H1          ' Sendbuffer in controller full
    Public Const CAN_ERR_OVERRUN As Integer = &H2          ' Read msg in CAN-Controller too late
    Public Const CAN_ERR_BUSLIGHT As Integer = &H4         ' Buserror: an errorcounter reached limit() As 0x0004
    Public Const CAN_ERR_BUSHEAVY As Integer = &H8         ' Buserror: an errorcounter reached limit() As 0x0008
    Public Const CAN_ERR_BUSOFF As Integer = &H10          ' Buserror: CAN controller is "Bus-Off"c() As 0x0010
    Public Const CAN_ERR_QRCVEMPTY As Integer = &H20       ' RcvQueue is empty() As 0x0020
    Public Const CAN_ERR_QOVERRUN As Integer = &H40        ' RcvQueue was read too late
    Public Const CAN_ERR_QXMTFULL As Integer = &H80        ' Sendequeue is full			        
    Public Const CAN_ERR_REGTEST As Integer = &H100        ' Error while try to check register of SJA100. no hardware detect
    Public Const CAN_ERR_NOVXD As Integer = &H200          ' Driver not loaded, no rights for license, trial license is expired...
    Public Const CAN_ERR_RESOURCE As Integer = &H2000      ' Could not create resource (FIFO, Client, Timeout)
    Public Const CAN_ERR_ILLPARAMTYPE As Integer = &H4000  ' Wrong parameter
    Public Const CAN_ERR_ILLPARAMVAL As Integer = &H8000   ' Wrong parameter type II
    Public Const CAN_ERRMASK_ILLHANDLE As Integer = &H1C00 ' Bit mask for handle error
    Public Const CAN_ERR_ANYBUSERR As Integer = (CAN_ERR_BUSLIGHT Or CAN_ERR_BUSHEAVY Or CAN_ERR_BUSOFF)
#End Region

    ' CAN message
    <StructLayout(LayoutKind.Sequential, Pack:=1)> Public Structure TCANMsg
        Public ID As Integer   ' 11/29 bit identifier() As ID
        Public MSGTYPE As Byte ' Bits from MSGTYPE_*() As MSGTYPE
        Public LEN As Byte     ' Data Length Code of the Msg (0..8)() As LEN
        <MarshalAs(UnmanagedType.ByValArray, sizeconst:=8)> _
        Public DATA As Byte()  ' Data array 1 bis 8 Datenbyte
    End Structure

    '/////////////////////////////////////////////////////////////////////////////
    '  Init()
    '  Aktiviert eine Hardware, macht Registertest des 82C200/SJA1000,
    '  teilt einen Sendepuffer und ein HardwareHandle zu.
    '  Programmiert Konfiguration der Sende/Empfangstreiber.
    '  Controller bleibt im Resetzustand.
    '  Uebergibt die Baudratenregister
    '  Wenn CANMsgType=0  ---> 11Bit ID Betrieb
    '  Wenn CANMsgType=1  ---> 11/29Bit ID Betrieb
    '  moegliche Fehler: NOVXD ILLHW REGTEST RESOURCE

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_Init")> _
    Public Shared Function init(ByVal BTR0BTR1 As Int16, ByVal CANMsgtype As Integer) As Int32
    End Function


    '/////////////////////////////////////////////////////////////////////////////
    '  Close()
    '  alles beenden und Hardware freigeben
    '  moegliche Fehler: NOVXD

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_Close")> _
    Public Shared Function Close() As Integer
    End Function


    '/////////////////////////////////////////////////////////////////////////////
    '  Status()
    '  aktuellen Status (zB BUS-OFF) der Hardware zurueckgeben
    '  moegliche Fehler: NOVXD BUSOFF BUSHEAVY OVERRUN

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_Status")> _
    Public Shared Function Status() As Integer
    End Function


    '/////////////////////////////////////////////////////////////////////////////
    '  Write()
    '  Schreibt eine Message
    '  moegliche Fehler: NOVXD RESOURCE BUSOFF QXMTFULL

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_Write")> _
    Public Shared Function Write(ByRef msg As TCANMsg) As Integer
    End Function

    '/////////////////////////////////////////////////////////////////////////////
    '  Read()
    '  gibt die naechste Message oder den naechsten Fehler aus dem
    '  RCV-Queue des Clients zurueck.
    '  Message wird nach 'msgbuff' geschrieben.
    '  moegliche Fehler: NOVXD  QRCVEMPTY

    <DllImport("PCAN_USB.dll", EnTryPoint:="CAN_Read")> _
    Public Shared Function Read(ByRef msg As TCANMsg) As Integer
    End Function

    '/////////////////////////////////////////////////////////////////////////////
    '  VersionInfo()
    '  Holt Treiberinformationen (Version, (c) usw...)

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_VersionInfo")> _
    Public Shared Function VersionInfo(ByVal buffer As StringBuilder) As Integer
    End Function

    '///////////////////////////////////////////////////////////////////////////////
    '  CAN_SpecialFunktion()
    '  erwartet eine long Zahl als Kennung und ein Integer als Codenummer
    '  gibt 1 zurueck wenn Codenummer und Kennung mit Donglehardware uebereinstimmen
    '	sonst 0
    '  nur fuer Distributoren !!

    <DllImport("PCAN_USB.dll", EntryPoint:="CAN_SpecialFunktion")> _
    Public Shared Function SpecialFunktion(ByVal distributorcode As Long, ByVal codenumber As UInt32) As Integer
    End Function

End Class
