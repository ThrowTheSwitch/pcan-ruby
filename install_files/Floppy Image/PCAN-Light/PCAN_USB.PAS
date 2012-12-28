unit pcan_usb;

//PCAN-Light
//PCAN-USB.PAS

//
//  ------------------------------------------------------------------
//  Copyright (C) 1995-2003 by PEAK-System Technik GmbH, Darmstadt
//



///////////////////////////////////////////////////////////////////////////////
//  Based on:
//  PCAN_USB.h
//  Version 1.4
//  Funktion:
//
//
//  Grundidee:
//  ~~~~~~~~~~
//  Der Treiber unterstuetzt eine Hardware und eine Software die mit CAN-Bussen kommunizieren wollen
//
//  PCAN-Light -API
//
//  ~~~~~~~~~~~~
//    CAN_Init(WORD    wBTR0BTR1, int CANMsgType)
//   //Hardware aktivieren und Baudrate uebergebn, Stand. oder Ext. Frame, IOPort und Interrupt
//
//   CAN_Read(TCANMsg *PCANMsg)  //Lesen einer CAN Nachricht
//
//   CAN_Write(TCANMsg *PCANMsg) //Schreiben einer CAN-Nachricht
//
//   CAN_Status(void) //Status der CAN-Hardware / Treiber
//
//   CAN_Close(void)  //Abmelden von Hardware und Treiber/
//
//   CAN_VersionInfo(LPSTR lpszTextBuff) ////  gibt einen Textstring mit Version- und Copyrightinfo
//
//
//  Autor  : Hoppe, Wilhelm
//  Sprache: ANSI-C; Pascal
//
//  ------------------------------------------------------------------
//  Copyright (C) 1999-2003 PEAK-System Technik GmbH, Darmstadt
//


interface 

// Konstantendefinitionen

const



//////////////////////////////////////////////////////////////////////
//Fuer CAN_Init
//////////////////////////////////////////////////////////////////////


// Laenge der CAN-Identifier

  CAN_MAX_STANDARD_ID = $7ff;
  CAN_MAX_EXTENDED_ID = $1fffffff;



  // Baudratencodes zur Uebergabe an 'CAN_Init()'
  CAN_BAUD_1M   =  $0014;       //   1 MBit / s
  CAN_BAUD_500K =  $001C;       // 500 kBit / s
  CAN_BAUD_250K =  $011C;       // 250 kBit / s
  CAN_BAUD_125K =  $031C;       // 125 kBit / s
  CAN_BAUD_100K =  $432F;       // 100 kBit / s
  CAN_BAUD_50K  =  $472F;       //  50 kBit / s
  CAN_BAUD_20K  =  $532F;       //  20 kBit / s
  CAN_BAUD_10K  =  $672F;       //  10 kBit / s
  CAN_BAUD_5K   =  $7F7F;       //   5 kBit / s


//Eigene Baudraten koennen ueber BTR0BTR1 eingestellt werden !!


// Msg Type:
	CAN_INIT_TYPE_EX = $01;	//Extended Frame
	CAN_INIT_TYPE_ST = $00;	//Standart Frame



  // Fehlerzustaende
  CAN_ERR_OK         = $0000;
  CAN_ERR_XMTFULL    = $0001;   // Sendepuffer im Controller ist voll
  CAN_ERR_OVERRUN    = $0002;   // CAN-Controller wurde zu spaet gelesen
  CAN_ERR_BUSLIGHT   = $0004;   // Busfehler: ein Errorcounter erreichte Limit
  CAN_ERR_BUSHEAVY   = $0008;   // Busfehler: ein Errorcounter erreichte Limit
  CAN_ERR_BUSOFF     = $0010;   // Busfehler: CAN_Controller ging 'Bus-Off'
  CAN_ERR_QRCVEMPTY  = $0020;   // RcvQueue ist leergelesen
  CAN_ERR_QOVERRUN   = $0040;   // RcvQueue wurde zu spaet gelesen
  CAN_ERR_QXMTFULL   = $0080;   // Sendequeue ist voll
  CAN_ERR_REGTEST    = $0100;   // RegisterTest des 82C200/SJA1000 schlug fehl
  CAN_ERR_NOVXD      = $0200;   // Problem mit Lokalisierung des VxD
  CAN_ERRMASK_ILLHANDLE=$1C00;  // Maske fuer alle Handlefehler
  CAN_ERR_HWINUSE    = $0400;   // Hardware ist von Netz belegt
  CAN_ERR_NETINUSE   = $0800;   // An Netz ist Client angeschlossen
  CAN_ERR_ILLHW      = $1400;   // Hardwarehandle war ungueltig
  CAN_ERR_ILLNET     = $1800;   // Netzhandle war ungueltig
  CAN_ERR_ILLCLIENT  = $1C00;   // Clienthandle war ungueltig
  CAN_ERR_RESOURCE   = $2000;   // Ressource (FIFO, Client, Timeout) nicht erzeugbar
  CAN_ERR_PARMTYP    = $4000;   // Parameter hier nicht erlaubt/anwendbar
  CAN_ERR_PARMVAL    = $8000;   // Parameterwert ist ungueltig



  CAN_ERR_ANYBUSERR = (CAN_ERR_BUSLIGHT or CAN_ERR_BUSHEAVY or CAN_ERR_BUSOFF);

// Alle weiteren Fehlerzustände <> 0 bei Bedarf bitte bei PEAK erfragen......interne Treiberfehler.....




// Die CAN Nachricht....und was dazu gehoert...

// Bits im Feld TCANMsg.MSGTYPE
  MSGTYPE_ERROR    = $80;  // 1, wenn Messageobject einen Fehler beschreibt
  MSGTYPE_EXTENDED = $02;  // 1, wenn CAN 2.0 B Frame (29 Bit ID)
  MSGTYPE_RTR      = $01;  // 1, wenn remote request, sonst data msg


type


// CAN_Message
  TPCANMsg = record
	ID: LongWord;       // 11/29 Bit-Kennung
	MSGTYPE: Byte;      // Bits aus MSGTYPE_*
	LEN: Byte;          // Anzahl der gueltigen Daten-Bytes (1..8)
	DATA: array[0..7] of Byte;    // Daten-Bytes 0..7
  end;



// Prototypen fuer Methoden



///////////////////////////////////////////////////////////////////////////////
//  CAN_Init()
//  Aktiviert eine Hardware, macht Registertest des 82C200/SJA1000,
//  teilt einen Sendepuffer und ein HardwareHandle zu.
//  Programmiert Konfiguration der Sende/Empfangstreiber.
//  Controller bleibt im Resetzustand.
//  Uebergibt die Baudratenregister
//  Wenn CANMsgType=0  ---> 11Bit ID Betrieb
//  Wenn CANMsgType=1  ---> 11/29Bit ID Betrieb
//
//  moegliche Fehler: NOVXD ILLHW REGTEST RESOURCE
// 



function CAN_Init(wBTR0BTR1: Word;
		  CANMsgType: Word): LongWord; stdcall;


///////////////////////////////////////////////////////////////////////////////
//  CAN_Close()
//  alles beenden und Hardware freigeben
//  moegliche Fehler: NOVXD
//

function CAN_Close: LongWord; stdcall;        


///////////////////////////////////////////////////////////////////////////////
//  CAN_Status()
//  aktuellen Status (zB BUS-OFF) der Hardware zurueckgeben
//  moegliche Fehler: NOVXD BUSOFF BUSHEAVY OVERRUN
//

function CAN_Status: LongWord; stdcall;        



///////////////////////////////////////////////////////////////////////////////
//  CAN_Write()
//  Schreibt eine Message 
//  moegliche Fehler: NOVXD RESOURCE BUSOFF QXMTFULL
//

function CAN_Write(var MsgBuff: TPCANMsg): LongWord; stdcall;


///////////////////////////////////////////////////////////////////////////////
//  CAN_Read()
//  gibt die naechste Message oder den naechsten Fehler aus dem
//  RCV-Queue des Clients zurueck.
//
//  CAN_Read() gibt die nächste Message oder den nächsten Fehler aus dem RCV-Queue des Clients zurück. Message wird
//  nach 'msgbuff' geschrieben. ACHTUNG der MSG_Type  gibt an ob es sich um eine 11Bit, 29Bit, RTR oder Status
//  Nachricht handelt. IMMER abfragen !. 
//  
//  Ist die gelesene CAN Nachricht keine normale Nachricht sondern eine Statusmeldung so ist der Rueckgabewert 
//  der CAN_Read() Funktion weiterhin CAN_ERR_OK, jedoch ist in TPCAN_MSG Struktur der MSGTYPE = MSGTYPE_STATUS.
//  
//  Identifier und Laegencode einer solchen Statusnachricht duerfen nicht ausgewertet werden (undefinierte Werte).
//  Die eigentliche Information ueber den Fehler lassen sich nun aus den ersten 4 Datenbytes der Nachricht 
//  herauslesen:
//  
//  Data0 Data1 Data2 Data3    Fehlertyp
//  0x00  0x00  0x00  0x02	== CAN_ERR_OVERRUN   0x0002  // CAN-Controller wurde zu spaet gelesen
//  0x00  0x00  0x00  0x04	== CAN_ERR_BUSLIGHT  0x0004  // Busfehler: ein Errorcounter erreichte Limit (96)
//  0x00  0x00  0x00  0x08	== CAN_ERR_BUSHEAVY  0x0008  // Busfehler: ein Errorcounter erreichte Limit (128)
//  
//  0x00  0x00  0x00  0x10	== CAN_ERR_BUSOFF    0x0010  // Busfehler: CAN_Controller ging 'Bus-Off'
//  
//  Beim Empfangen einer BUSOFF Statusnachricht ist der CAN-Controller mit CAN_Init() neu zu initialisieren,
//  da sonst keine Nachrichtem mehr gesendet werden koennen!
//  
//  
//  Message wird nach 'msgbuff' geschrieben.
//  moegliche Fehler: NOVXD  QRCVEMPTY
//

function CAN_Read(var MsgBuff: TPCANMsg): LongWord; stdcall;


///////////////////////////////////////////////////////////////////////////////
//  CAN_VersionInfo()
//  gibt einen Textstring mit Version- und Copyrightinfo
//  zurueck (max. 255 Zeichen).
//  moegliche Fehler: NOVXD
//

function CAN_VersionInfo(
		lpszTextBuff: PChar          // Zeiger auf Textstring
		): LongWord; stdcall;


implementation

uses SysUtils; // Fuer Exceptions

const DLL_Name = 'pcan_usb.dll';


function CAN_Init(wBTR0BTR1: Word; CANMsgType: Word): LongWord; stdcall;
external DLL_Name;


function CAN_Close: LongWord; stdcall;
external DLL_Name;

function CAN_Status: LongWord; stdcall;
external DLL_Name;

function CAN_Write(var MsgBuff: TPCANMsg): LongWord; stdcall;
external DLL_Name;

function CAN_Read(var MsgBuff: TPCANMsg): LongWord; stdcall;
external DLL_Name;

function CAN_VersionInfo(lpszTextBuff: PChar): LongWord; stdcall;
external DLL_Name;


end.
