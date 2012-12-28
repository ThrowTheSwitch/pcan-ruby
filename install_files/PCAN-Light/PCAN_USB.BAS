Attribute VB_Name = "PCAN_USB"
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  VB Deklarations for PCAN-Light Driver USB
'  (c) 2003 PEAK-System Technik GmbH
'  Autor:U.Wilhelm
'  rev. 1.4
'  01.03.2003
'
' This software is NO freeware
' You are only allowed to use this software if you have hardware from
' PEAK-System Technik GmbH
'
' do not use the software or parts from it for communicate with non PEAK-Software
'
' if you like a more performant and powerfull device driver take a look at the
' PCAN-Tools which allowed
' - full buffered send/transmit by driver (up to 512 CAN-Msg )
' - timerresolution 1 ms (Win9x/ME) or 10 ms (NT/2000)
' - callback function for receive
' - define Msg filter for application
' - write one software for all hardware ( no recompile )
' - communication between every hard & software
' - powerfull development  tools (monitor, logger etc.)
'
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

'
' Public Const
'

Public Const CAN_MAX_STANDARD_ID = &H7FF
Public Const CAN_MAX_EXTENDED_ID = &H1FFFFFFF

' BTR0BTR1 register
' Baudratecode = register value BTR0/BTR1
Public Const CAN_BAUD_1M = &H14        '   1 MBit / s
Public Const CAN_BAUD_500K = &H1C      ' 500 kBit / s
Public Const CAN_BAUD_250K = &H11C     ' 250 kBit / s
Public Const CAN_BAUD_125K = &H31C     ' 125 kBit / s
Public Const CAN_BAUD_100K = &H432F    ' 100 kBit / s
Public Const CAN_BAUD_50K = &H472F     '  50 kBit / s
Public Const CAN_BAUD_20K = &H532F     '  20 kBit / s
Public Const CAN_BAUD_10K = &H672F     '  10 kBit / s
Public Const CAN_BAUD_5K = &H7F7F      '   5 kBit / s

' you can define your own Baudrate with the BTROBTR1 register !!
' take a look at www.peak-system.com for our software BAUDTOOL to
' calculate the BTROBTR1 register for every baudrate and sample point.


' Msg Type:
Public Const CAN_INIT_TYPE_EX = &H1     '  Extended Frame
Public Const CAN_INIT_TYPE_ST = &H0     ' Standart Frame



'  error codes (bit code)
Public Const CAN_ERR_OK = &H0                ' no error -- everithing OK
Public Const CAN_ERR_XMTFULL = &H1           ' sendbuffer in controller full
Public Const CAN_ERR_OVERRUN = &H2           ' read Msg in CAN-Controller to late
Public Const CAN_ERR_BUSLIGHT = &H4          ' Buserror: a errorcounter reached his limit
Public Const CAN_ERR_BUSHEAVY = &H8          ' Buserror: a errorcounter reached his limit
Public Const CAN_ERR_BUSOFF = &H10           ' Buserror: CAN_Controller is 'Bus-Off'
Public Const CAN_ERR_QRCVEMPTY = &H20        ' RcvQueue is empty
Public Const CAN_ERR_QOVERRUN = &H40         ' RcvQueue was read to late
Public Const CAN_ERR_QXMTFULL = &H80         ' Sendequeue is full
Public Const CAN_ERR_REGTEST = &H100         ' error while try to check register of SJA100. no hardware detect
Public Const CAN_ERR_NOVXD = &H200           ' driver not load, no rights for lizens, time for temp liszens is over...
Public Const CAN_ERR_RESOURCE = &H2000       ' could not create resource (FIFO, Client, Timeout)
Public Const CAN_ERR_ILLPARAMTYPE = &H4000   ' wrong parameter
Public Const CAN_ERR_ILLPARAMVAL = &H8000    ' wrong parameter type II
Public Const CAN_ERRMASK_ILLHANDLE = &H1C00  ' bit mask for handle error

Public Const CAN_ERR_ANYBUSERR = (CAN_ERR_BUSLIGHT Or CAN_ERR_BUSHEAVY Or CAN_ERR_BUSOFF)


' the can msg...and the addons .......
Public Const MSGTYPE_STATUS = &H80     ' 1, if Msg is a status Msg
Public Const MSGTYPE_EXTENDED = &H2    ' 1, if CAN 2.0 B Frame (29 Bit ID)
Public Const MSGTYPE_RTR = &H1         ' 1, if remote request, if 0 a data Msg


' CAN_Message
Public Type TPCANMsg
    ID As Long          ' 11/29 Bit-Identif.
    MSGTYPE As Byte     ' Bits from MSGTYPE_*
    LEN As Byte         ' len of databyte for the Msg (0.8)
    DATA(7) As Byte     ' data bytes 0..7
End Type




' Functions  -- GERMAN Description --

'///////////////////////////////////////////////////////////////////////////////
'//  CAN_Init()
'//  Aktiviert eine Hardware, macht Registertest des 82C200/SJA1000,
'//  teilt einen Sendepuffer und ein HardwareHandle zu.
'//  Programmiert Konfiguration der Sende/Empfangstreiber.
'//  Controller bleibt im Resetzustand.
'//  Uebergibt die Baudratenregister
'//  Wenn CANMsgType=0  ---> 11Bit ID Betrieb
'//  Wenn CANMsgType=1  ---> 11/29Bit ID Betrieb
'//  moegliche Fehler: NOVXD ILLHW REGTEST RESOURCE
'//

Public Declare Function CAN_Init Lib "pcan_usb" _
        (ByVal wBTR0BTR1 As Integer, ByVal CANMsgType As Integer) As Long



'///////////////////////////////////////////////////////////////////////////////
'//  CAN_Close()
'//  alles beenden und Hardware freigeben
'//  moegliche Fehler: NOVXD
'//

Public Declare Function CAN_Close Lib "pcan_usb" _
         () As Long



'///////////////////////////////////////////////////////////////////////////////
'//  CAN_Status()
'//  aktuellen Status (zB BUS-OFF) der Hardware zurueckgeben
'//  moegliche Fehler: NOVXD BUSOFF BUSHEAVY OVERRUN
'//

Public Declare Function CAN_Status Lib "pcan_usb" _
        () As Long



'///////////////////////////////////////////////////////////////////////////////
'//  CAN_Write()
'//  Schreibt eine Message
'//  moegliche Fehler: NOVXD RESOURCE BUSOFF QXMTFULL
'//

Public Declare Function CAN_Write Lib "pcan_usb" _
        (ByRef pMsgBuff As TPCANMsg) As Long



'///////////////////////////////////////////////////////////////////////////////
'//  CAN_Read()
'//  gibt die naechste Message oder den naechsten Fehler aus dem
'//  RCV-Queue des Clients zurueck.
'//  
'//  CAN_Read() gibt die nächste Message oder den nächsten Fehler aus dem RCV-Queue des Clients zurück. Message wird
'//  nach 'msgbuff' geschrieben. ACHTUNG der MSG_Type  gibt an ob es sich um eine 11Bit, 29Bit, RTR oder Status
'//  Nachricht handelt. IMMER abfragen !. 
'//  
'//  Ist die gelesene CAN Nachricht keine normale Nachricht sondern eine Statusmeldung so ist der Rueckgabewert 
'//  der CAN_Read() Funktion weiterhin CAN_ERR_OK, jedoch ist in TPCAN_MSG Struktur der MSGTYPE = MSGTYPE_STATUS.
'//  
'//  Identifier und Laegencode einer solchen Statusnachricht duerfen nicht ausgewertet werden (undefinierte Werte).
'//  Die eigentliche Information ueber den Fehler lassen sich nun aus den ersten 4 Datenbytes der Nachricht 
'//  herauslesen:
'//  
'//  Data0 Data1 Data2 Data3    Fehlertyp
'//  0x00  0x00  0x00  0x02	== CAN_ERR_OVERRUN   0x0002  // CAN-Controller wurde zu spaet gelesen
'//  0x00  0x00  0x00  0x04	== CAN_ERR_BUSLIGHT  0x0004  // Busfehler: ein Errorcounter erreichte Limit (96)
'//  0x00  0x00  0x00  0x08	== CAN_ERR_BUSHEAVY  0x0008  // Busfehler: ein Errorcounter erreichte Limit (128)
'//  
'//  0x00  0x00  0x00  0x10	== CAN_ERR_BUSOFF    0x0010  // Busfehler: CAN_Controller ging 'Bus-Off'
'//  
'//  Beim Empfangen einer BUSOFF Statusnachricht ist der CAN-Controller mit CAN_Init() neu zu initialisieren,
'//  da sonst keine Nachrichtem mehr gesendet werden koennen!
'//  
'//  Message wird nach 'msgbuff' geschrieben.
'//  moegliche Fehler: NOVXD  QRCVEMPTY
'//

Public Declare Function CAN_Read Lib "pcan_usb" _
        (ByRef pMsgBuff As TPCANMsg) As Long



'///////////////////////////////////////////////////////////////////////////////
'//  CAN_VersionInfo()
'//  Holt Treiberinformationen (Version, (c) usw...)
'//

Public Declare Function CAN_VersionInfo Lib "pcan_usb" _
        (ByVal lpBuffer As String) As Long


