//PCAN-Light
//PCAN-USB.H

#ifndef __PCANPCIH__        // Schutz gegen mehrfaches #include
#define __PCANPCIH__



///////////////////////////////////////////////////////////////////////////////
//  PCAN_USB.h
//  Version 1.4
//  Funktion:
//  Definition der PCAN-Light API. Aenderungen auch in PAS abgleichen.
//
//
//  Grundidee:
//  ~~~~~~~~~~
//  Der Treiber unterstuetzt eine Hardware und eine Software die mit CAN-Bussen kommunizieren wollen
//
//  PCAN-Light -API
//
//  ~~~~~~~~~~~~
//   CAN_Init( WORD    wBTR0BTR1, int Type)  //Hardware aktivieren und Baudrate uebergebn, Stand. oder Ext. Frame
//
//   CAN_Read(TCANMsg *PCANMsg)  //Lesen einer CAN Nachricht
//
//   CAN_Write(TCANMsg *PCANMsg) //Schreiben einer CAN-Nachricht
//
//   CAN_Status(void) //Status der CAN-Hardware / Treiber
//
//   CAN_Close(void)  //Abmelden von Hardware und Treiber/
//
//   CAN_VersionInfo(LPSTR lpszTextBuff) //  gibt einen Textstring mit Version- und Copyrightinfo
//
//   CAN_ResetClient(void) //  l�scht die beiden Nachrichten queues des Clients 
//
//   CAN_MsgFilter(DWORD FromID,DWORD ToID, int Type) //  Registrierung von Nachrichten 
//
//   CAN_ResetFilter(void) //  Reset der CAN-Filter--Es werden KEINE Nachrichten mehr empfangen
//
//   SetUSBDeviceNr(long uDevNo) //  setzt die DeviceNr des USB auf den Wert l
//
//   GetUSBDeviceNr(long *uDevNo) //  liest die DeviceNr des USB 
//
//  Autor  : Hoppe, Wilhelm
//  Sprache: ANSI-C
//
//  ------------------------------------------------------------------
//  Copyright (C) 1999-2005  PEAK-System Technik GmbH, Darmstadt
//


// Konstantendefinitionen

#define CAN_MAX_STANDARD_ID     0x7ff
#define CAN_MAX_EXTENDED_ID     0x1fffffff




//////////////////////////////////////////////////////////////////////
//Fuer CAN_Init
//////////////////////////////////////////////////////////////////////


// BTR0BTR1 register 
// Baudratencodes = Registerwerte BTR0/BTR1
#define CAN_BAUD_1M     0x0014  //   1 MBit/s
#define CAN_BAUD_500K   0x001C  // 500 kBit/s
#define CAN_BAUD_250K   0x011C  // 250 kBit/s
#define CAN_BAUD_125K   0x031C  // 125 kBit/s
#define CAN_BAUD_100K   0x432F  // 100 kBit/s
#define CAN_BAUD_50K    0x472F  //  50 kBit/s
#define CAN_BAUD_20K    0x532F  //  20 kBit/s
#define CAN_BAUD_10K    0x672F  //  10 kBit/s
#define CAN_BAUD_5K     0x7F7F  //   5 kBit/s
//Eigene Baudraten koennen ueber BTR0BTR1 eingestellt werden !!


// Msg Type:
#define CAN_INIT_TYPE_EX		0x01	//Extended Frame
#define CAN_INIT_TYPE_ST		0x00	//Standart Frame 



//////////////////////////////////////////////////////////////////////
// Fehlerzustaende
//////////////////////////////////////////////////////////////////////

#define CAN_ERR_OK             0x0000  // Kein Fehler 
#define CAN_ERR_XMTFULL        0x0001  // Sendepuffer im Controller ist voll
#define CAN_ERR_OVERRUN        0x0002  // CAN-Controller wurde zu spaet gelesen
#define CAN_ERR_BUSLIGHT       0x0004  // Busfehler: ein Errorcounter erreichte Limit
#define CAN_ERR_BUSHEAVY       0x0008  // Busfehler: ein Errorcounter erreichte Limit
#define CAN_ERR_BUSOFF         0x0010  // Busfehler: CAN_Controller ging 'Bus-Off'
#define CAN_ERR_QRCVEMPTY      0x0020  // RcvQueue ist leergelesen
#define CAN_ERR_QOVERRUN       0x0040  // RcvQueue wurde zu spaet gelesen
#define CAN_ERR_QXMTFULL       0x0080  // Sendequeue ist voll
#define CAN_ERR_REGTEST        0x0100  // RegisterTest des 82C200/SJA100 schlug fehl
#define CAN_ERR_NOVXD          0x0200  // VxD nicht geladen, Lizenz ausgelaufen  :-)
#define CAN_ERR_HWINUSE        0x0400  // Hardware ist vom Netz belegt
#define CAN_ ERR_NETINUSE      0x0800  // Am Netz ist mindestens ein Client angeschlossen.
#define CAN_ERR_ILLHW	       0x1400  // Hardware-Handle ist ung�ltig.
#define CAN_ERR_ILLNET         0x1800  // Receive-Queue ist leergelesen.
#define CAN_ERR_ILLCLIENT      0x1C00  // Client-Handle ist ung�ltig.
#define CAN_ERR_RESOURCE       0x2000  // Resource (FIFO, Client, Timeout) nicht erzeugbar
#define CAN_ERR_ILLPARAMTYPE   0x4000  // Parameter hier nicht erlaubt/anwendbar
#define CAN_ERR_ILLPARAMVAL    0x8000  // Parameterwert ist ungueltig
#define CAN_ERR_UNKNOWN        0x10000 // Unbekannter Fehler
#define CAN_ERRMASK_ILLHANDLE  0x1C00  // Maske fuer alle Handlefehler
#define CAN_ERR_ANYBUSERR (CAN_ERR_BUSLIGHT | CAN_ERR_BUSHEAVY | CAN_ERR_BUSOFF)

// Alle weiteren Fehlerzust�nde <> 0 bei Bedarf bitte bei PEAK erfragen......interne Treiberfehler.....

/* Error codes English
#define CAN_ERR_OK            0x0000  // No error
#define CAN_ERR_XMTFULL       0x0001  // Transmit buffer in CAN controller is full
#define CAN_ERR_OVERRUN       0x0002  // CAN controller was read too late ..
#define CAN_ERR_BUSLIGHT      0x0004  // Bus error: an error counter reached the 'light' limit
#define CAN_ERR_BUSHEAVY      0x0008  // Bus error: an error counter reached the 'heavy' limit
#define CAN_ERR_BUSOFF        0x0010  // Bus error: the CAN controller is in bus-off state
#define CAN_ERR_QRCVEMPTY     0x0020  // Receive queue is empty
#define CAN_ERR_QOVERRUN      0x0040  // Receive queue was read too late
#define CAN_ERR_QXMTFULL      0x0080  // Transmit queue ist full
#define CAN_ERR_REGTEST       0x0100  // Test of the CAN controller hardware registers failed (no hardware found)
#define CAN_ERR_NOVXD         0x0200  // Driver not loaded, maybe the license is exceeded
#define CAN_ERRMASK_ILLHANDLE 0x1C00  // Mask for all handle errors
#define CAN_ERR_HWINUSE       0x0400  // Hardware is in use by another Net
#define CAN_ERR_NETINUSE      0x0800  // a Client is already connected to the Net
#define CAN_ERR_ILLHW         0x1400  // Hardware handle is wrong
#define CAN_ERR_ILLNET        0x1800  // Net handle is wrong
#define CAN_ERR_ILLCLIENT     0x1C00  // Client handle is wrong
#define CAN_ERR_RESOURCE      0x2000  // Resource (FIFO, Client, timeout) cannot be created
#define CAN_ERR_ILLPARAMTYPE  0x4000  // Invalid parameter
#define CAN_ERR_ILLPARAMVAL   0x8000  // Invalid parameter value
#define CAN_ERR_UNKNOWN      0x10000  // Unknown error
#define CAN_ERR_ANYBUSERR (CAN_ERR_BUSLIGHT | CAN_ERR_BUSHEAVY | CAN_ERR_BUSOFF)
*/


//////////////////////////////////////////////////////////////////////
// Die CAN Nachricht
//////////////////////////////////////////////////////////////////////

// Msg Type for CANRead/Write:
#define MSGTYPE_STATUS   0x80   //  Status Message
#define MSGTYPE_EXTENDED 0x02   //  CAN 2.0 B Frame (29 Bit ID)
#define MSGTYPE_RTR      0x01   //  remote requestframe
#define MSGTYPE_STANDARD 0x00   //  STD Msg (11 Bit ID)


// eine CAN_Message
typedef struct {
    DWORD ID;        // 11/29 Bit-Kennung
    BYTE  MSGTYPE;   // Bits aus MSGTYPE_*
    BYTE  LEN;       // Anzahl der gueltigen Datenbytes (0.8)
    BYTE  DATA[8];   // Datenbytes 0..7
} TPCANMsg;


#ifdef NTVERSION
   #pragma pack(push, 1)    // diese Inforecords Byte-aligned! (MS Visual C++)
#endif

#ifdef NTVERSION
   #pragma pack(pop)        // wieder default alignment
#endif



//////////////////////////////////////////////////////////////////////
// Prototypen fuer Methoden
//////////////////////////////////////////////////////////////////////


#ifdef __cplusplus
  extern "C" {
#endif


///////////////////////////////////////////////////////////////////////////////
//  CAN_Init()
//  Aktiviert eine Hardware, macht Registertest des 82C200/SJA1000,
//  teilt einen Sendepuffer und ein HardwareHandle zu.
//  Programmiert Konfiguration der Sende/Empfangstreiber.
//  Controller bleibt im Resetzustand.
//  Uebergibt die Baudratenregister
//  Wenn CANMsgType=0  ---> 11Bit ID Betrieb
//  Wenn CANMsgType=1  ---> 11/29Bit ID Betrieb
//  moegliche Fehler: NOVXD ILLHW REGTEST RESOURCE
// 

DWORD __stdcall CAN_Init(WORD wBTR0BTR1, int CANMsgType);  // Baudrate
        


///////////////////////////////////////////////////////////////////////////////
//  CAN_Close()
//  alles beenden und Hardware freigeben
//  moegliche Fehler: NOVXD
//

DWORD __stdcall CAN_Close(void);


///////////////////////////////////////////////////////////////////////////////
//  CAN_Status()
//  aktuellen Status (zB BUS-OFF) der Hardware zurueckgeben
//  moegliche Fehler: NOVXD BUSOFF BUSHEAVY OVERRUN
//

DWORD __stdcall CAN_Status(void);


///////////////////////////////////////////////////////////////////////////////
//  CAN_Write()
//  Schreibt eine Message 
//  moegliche Fehler: NOVXD RESOURCE BUSOFF QXMTFULL
//

DWORD __stdcall CAN_Write( TPCANMsg* pMsgBuff);


///////////////////////////////////////////////////////////////////////////////
//  CAN_Read()
//  gibt die naechste Message oder den naechsten Fehler aus dem
//  RCV-Queue des Clients zurueck.
//
//  CAN_Read() gibt die n�chste Message oder den n�chsten Fehler aus dem RCV-Queue des Clients zur�ck. Message wird
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

DWORD __stdcall CAN_Read(TPCANMsg* pMsgBuff );


///////////////////////////////////////////////////////////////////////////////
//  CAN_VersionInfo()
//  gibt einen Textstring mit Version- und Copyrightinfo
//  zurueck (max. 255 Zeichen).
//  moegliche Fehler: NOVXD
//

DWORD __stdcall CAN_VersionInfo(LPSTR lpszTextBuff);



///////////////////////////////////////////////////////////////////////////////
//  CAN_SpecialFunktion()
//  erwartet eine long Zahl als Kennung und ein Integer als Codenummer
//  gibt 1 zurueck wenn Codenummer und Kennung mit Donglehardware uebereinstimmen
//	sonst 0
//  nur fuer Distributoren !!

DWORD __stdcall CAN_SpecialFunktion(unsigned long distributorcode, int codenumber );



//////////////////////////////////////////////////////////////////////////////
//  CAN_ResetClient()
//  l�scht die beiden Nachrichten queues des Clients ohne Controller durch 
//  einen RESET zu jagen..
//  moegliche Fehler: ERR_OK, ERR_ILLCLIENT, ERR_NOVXD
//

DWORD __stdcall CAN_ResetClient(void);


///////////////////////////////////////////////////////////////////////////////
//  CAN_MsgFilter(FromID, ToID, int Type)
//  setzt Filter auf von-bis
//  Anmeldung der Messages FromID bis 'ToID empfangen werden sollen.
//  FromID <= ToID 
//
//  Schnelle Registrierung aller Messages mit FromID=ToID=NULL.
//  Jeder Aufruf dieser Funktion bewirkt evtl. eine Erweiterung
//  des Empfangsfilters des betroffenen CAN-Controllers, der dadurch
//  kurz RESET gehen kann.
//
//  Neu in Ver 2.x: standard frames werden in den acc_mask/code
//                  als Bits 28..13 abgelegt.
//                  Hardwaretreiber fuer 82C200 muessen das
//                  wieder auf 10..0 schieben!
//  ACHTUNG: es ist nicht garantiert, dass NUR die
//           registrierten Messages empfaengt!
//  moegliche Fehler: NOVXD ILLCLIENT ILLNET REGTEST

DWORD __stdcall CAN_MsgFilter(DWORD FromID, DWORD ToID, int Type);


///////////////////////////////////////////////////////////////////////////////
//  CAN_ResetFilter()
//  Macht den Filter der Hardware komplett zu 
//  es werden KEINE Nachrichten mehr empfangen 
//  moegliche Fehler: NOVXD
//

DWORD __stdcall CAN_ResetFilter(void);


//////////////////////////////////////////////////////////////////////////////
//  SetUSBDeviceNr()
//  setzt die DeviceNr des USB auf den Wert l
//  moegliche Fehler: NOVXD ILLHW ILLPARAMTYPE ILLPARAMVAL REGTEST
//

DWORD __stdcall SetUSBDeviceNr(long l);


//////////////////////////////////////////////////////////////////////////////
//  GetUSBDeviceNr()
//  liest die DeviceNr des USB 
//  moegliche Fehler: NOVXD ILLHW ILLPARAMTYPE//

DWORD __stdcall GetUSBDeviceNr(long* l);



#ifdef __cplusplus
}
#endif


#endif // __PCANUSBH__
