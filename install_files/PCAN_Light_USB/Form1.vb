Imports System
Imports System.Drawing
Imports System.Collections
Imports System.ComponentModel
Imports System.Windows.Forms
Imports System.Data
Imports System.Text
Imports System.Runtime.InteropServices
Imports System.Runtime.InteropServices.Marshal
Imports System.Globalization

Namespace PCAN_USB_Demo.VB
    Public Class Form1
        Inherits System.Windows.Forms.Form

#Region " Vom Windows Form Designer generierter Code "

        Public Sub New()
            MyBase.New()

            ' Dieser Aufruf ist für den Windows Form-Designer erforderlich.
            InitializeComponent()

            ' Initialisierungen nach dem Aufruf InitializeComponent() hinzufügen

        End Sub

        ' Die Form überschreibt den Löschvorgang der Basisklasse, um Komponenten zu bereinigen.
        Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
            If disposing Then
                If Not (components Is Nothing) Then
                    components.Dispose()
                End If
            End If
            MyBase.Dispose(disposing)
        End Sub

        ' Für Windows Form-Designer erforderlich
        Private components As System.ComponentModel.IContainer

        'HINWEIS: Die folgende Prozedur ist für den Windows Form-Designer erforderlich
        'Sie kann mit dem Windows Form-Designer modifiziert werden.
        'Verwenden Sie nicht den Code-Editor zur Bearbeitung.
        Friend WithEvents VersionInfoButton As System.Windows.Forms.Button
        Friend WithEvents VersionLabel As System.Windows.Forms.Label
        Friend WithEvents InitButton As System.Windows.Forms.Button
        Friend WithEvents InitLabel As System.Windows.Forms.Label
        Friend WithEvents StatusButton As System.Windows.Forms.Button
        Friend WithEvents StatusLabel As System.Windows.Forms.Label
        Friend WithEvents ReadButton As System.Windows.Forms.Button
        Friend WithEvents CloseButton As System.Windows.Forms.Button
        Friend WithEvents ReadLabel As System.Windows.Forms.Label
        Friend WithEvents WriteButton As System.Windows.Forms.Button
        Friend WithEvents CloseLabel As System.Windows.Forms.Label
        Friend WithEvents ReadStatLabel As System.Windows.Forms.Label
        Friend WithEvents WriteStatLabel As System.Windows.Forms.Label
        Friend WithEvents WriteLabel As System.Windows.Forms.Label
        Friend WithEvents MultiReadCheckBox As System.Windows.Forms.CheckBox
        Friend WithEvents ReadListBox As System.Windows.Forms.ListBox
        Friend WithEvents ReadTimeUpDown As System.Windows.Forms.NumericUpDown
        Friend WithEvents TimerLabel As System.Windows.Forms.Label
        Friend WithEvents Timer1 As System.Windows.Forms.Timer
        Friend WithEvents StatusBar As System.Windows.Forms.StatusBar
        <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
            Me.components = New System.ComponentModel.Container
            Me.VersionInfoButton = New System.Windows.Forms.Button
            Me.VersionLabel = New System.Windows.Forms.Label
            Me.InitButton = New System.Windows.Forms.Button
            Me.InitLabel = New System.Windows.Forms.Label
            Me.StatusButton = New System.Windows.Forms.Button
            Me.StatusLabel = New System.Windows.Forms.Label
            Me.WriteButton = New System.Windows.Forms.Button
            Me.WriteStatLabel = New System.Windows.Forms.Label
            Me.ReadButton = New System.Windows.Forms.Button
            Me.CloseButton = New System.Windows.Forms.Button
            Me.ReadLabel = New System.Windows.Forms.Label
            Me.CloseLabel = New System.Windows.Forms.Label
            Me.ReadStatLabel = New System.Windows.Forms.Label
            Me.WriteLabel = New System.Windows.Forms.Label
            Me.MultiReadCheckBox = New System.Windows.Forms.CheckBox
            Me.ReadListBox = New System.Windows.Forms.ListBox
            Me.ReadTimeUpDown = New System.Windows.Forms.NumericUpDown
            Me.TimerLabel = New System.Windows.Forms.Label
            Me.Timer1 = New System.Windows.Forms.Timer(Me.components)
            Me.StatusBar = New System.Windows.Forms.StatusBar
            CType(Me.ReadTimeUpDown, System.ComponentModel.ISupportInitialize).BeginInit()
            Me.SuspendLayout()
            '
            'VersionInfoButton
            '
            Me.VersionInfoButton.Location = New System.Drawing.Point(176, 8)
            Me.VersionInfoButton.Name = "VersionInfoButton"
            Me.VersionInfoButton.Size = New System.Drawing.Size(136, 24)
            Me.VersionInfoButton.TabIndex = 0
            Me.VersionInfoButton.Text = "CAN_VersionInfo"
            '
            'VersionLabel
            '
            Me.VersionLabel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
            Me.VersionLabel.Location = New System.Drawing.Point(96, 47)
            Me.VersionLabel.Name = "VersionLabel"
            Me.VersionLabel.Size = New System.Drawing.Size(304, 72)
            Me.VersionLabel.TabIndex = 1
            '
            'InitButton
            '
            Me.InitButton.Location = New System.Drawing.Point(8, 134)
            Me.InitButton.Name = "InitButton"
            Me.InitButton.Size = New System.Drawing.Size(88, 24)
            Me.InitButton.TabIndex = 2
            Me.InitButton.Text = "CAN_Init"
            '
            'InitLabel
            '
            Me.InitLabel.Location = New System.Drawing.Point(104, 138)
            Me.InitLabel.Name = "InitLabel"
            Me.InitLabel.Size = New System.Drawing.Size(360, 16)
            Me.InitLabel.TabIndex = 3
            '
            'StatusButton
            '
            Me.StatusButton.Enabled = False
            Me.StatusButton.Location = New System.Drawing.Point(8, 166)
            Me.StatusButton.Name = "StatusButton"
            Me.StatusButton.Size = New System.Drawing.Size(88, 24)
            Me.StatusButton.TabIndex = 4
            Me.StatusButton.Text = "CAN_Status"
            '
            'StatusLabel
            '
            Me.StatusLabel.Location = New System.Drawing.Point(104, 170)
            Me.StatusLabel.Name = "StatusLabel"
            Me.StatusLabel.Size = New System.Drawing.Size(80, 16)
            Me.StatusLabel.TabIndex = 5
            '
            'WriteButton
            '
            Me.WriteButton.Enabled = False
            Me.WriteButton.Location = New System.Drawing.Point(8, 198)
            Me.WriteButton.Name = "WriteButton"
            Me.WriteButton.Size = New System.Drawing.Size(88, 24)
            Me.WriteButton.TabIndex = 6
            Me.WriteButton.Text = "CAN_Write"
            '
            'WriteStatLabel
            '
            Me.WriteStatLabel.Location = New System.Drawing.Point(104, 202)
            Me.WriteStatLabel.Name = "WriteStatLabel"
            Me.WriteStatLabel.Size = New System.Drawing.Size(80, 16)
            Me.WriteStatLabel.TabIndex = 7
            '
            'ReadButton
            '
            Me.ReadButton.Enabled = False
            Me.ReadButton.Location = New System.Drawing.Point(8, 230)
            Me.ReadButton.Name = "ReadButton"
            Me.ReadButton.Size = New System.Drawing.Size(88, 24)
            Me.ReadButton.TabIndex = 8
            Me.ReadButton.Text = "CAN_Read"
            '
            'CloseButton
            '
            Me.CloseButton.Enabled = False
            Me.CloseButton.Location = New System.Drawing.Point(6, 389)
            Me.CloseButton.Name = "CloseButton"
            Me.CloseButton.Size = New System.Drawing.Size(88, 24)
            Me.CloseButton.TabIndex = 9
            Me.CloseButton.Text = "CAN_Close"
            '
            'ReadLabel
            '
            Me.ReadLabel.Location = New System.Drawing.Point(191, 236)
            Me.ReadLabel.Name = "ReadLabel"
            Me.ReadLabel.Size = New System.Drawing.Size(273, 16)
            Me.ReadLabel.TabIndex = 10
            Me.ReadLabel.Visible = False
            '
            'CloseLabel
            '
            Me.CloseLabel.Location = New System.Drawing.Point(101, 393)
            Me.CloseLabel.Name = "CloseLabel"
            Me.CloseLabel.Size = New System.Drawing.Size(80, 16)
            Me.CloseLabel.TabIndex = 11
            '
            'ReadStatLabel
            '
            Me.ReadStatLabel.Location = New System.Drawing.Point(104, 234)
            Me.ReadStatLabel.Name = "ReadStatLabel"
            Me.ReadStatLabel.Size = New System.Drawing.Size(80, 16)
            Me.ReadStatLabel.TabIndex = 12
            '
            'WriteLabel
            '
            Me.WriteLabel.Location = New System.Drawing.Point(192, 203)
            Me.WriteLabel.Name = "WriteLabel"
            Me.WriteLabel.Size = New System.Drawing.Size(264, 16)
            Me.WriteLabel.TabIndex = 13
            Me.WriteLabel.Text = "ID: 100   LEN: 8   DATA: 12 34 56 78 90 AB CD EF"
            Me.WriteLabel.Visible = False
            '
            'MultiReadCheckBox
            '
            Me.MultiReadCheckBox.Location = New System.Drawing.Point(8, 264)
            Me.MultiReadCheckBox.Name = "MultiReadCheckBox"
            Me.MultiReadCheckBox.Size = New System.Drawing.Size(176, 24)
            Me.MultiReadCheckBox.TabIndex = 14
            Me.MultiReadCheckBox.Text = "CAN multi reading"
            '
            'ReadListBox
            '
            Me.ReadListBox.Items.AddRange(New Object() {"###############", "  No CAN messages", "###############"})
            Me.ReadListBox.Location = New System.Drawing.Point(184, 266)
            Me.ReadListBox.Name = "ReadListBox"
            Me.ReadListBox.Size = New System.Drawing.Size(272, 147)
            Me.ReadListBox.TabIndex = 15
            '
            'ReadTimeUpDown
            '
            Me.ReadTimeUpDown.Location = New System.Drawing.Point(8, 292)
            Me.ReadTimeUpDown.Maximum = New Decimal(New Integer() {2500, 0, 0, 0})
            Me.ReadTimeUpDown.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
            Me.ReadTimeUpDown.Name = "ReadTimeUpDown"
            Me.ReadTimeUpDown.Size = New System.Drawing.Size(56, 20)
            Me.ReadTimeUpDown.TabIndex = 16
            Me.ReadTimeUpDown.Value = New Decimal(New Integer() {100, 0, 0, 0})
            '
            'TimerLabel
            '
            Me.TimerLabel.Location = New System.Drawing.Point(72, 294)
            Me.TimerLabel.Name = "TimerLabel"
            Me.TimerLabel.Size = New System.Drawing.Size(80, 16)
            Me.TimerLabel.TabIndex = 17
            Me.TimerLabel.Text = "intervall in ms"
            '
            'Timer1
            '
            '
            'StatusBar
            '
            Me.StatusBar.Location = New System.Drawing.Point(0, 429)
            Me.StatusBar.Name = "StatusBar"
            Me.StatusBar.Size = New System.Drawing.Size(472, 16)
            Me.StatusBar.TabIndex = 18
            Me.StatusBar.Text = "HARWARE IS NOT INITIALIZED"
            '
            'Form1
            '
            Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
            Me.ClientSize = New System.Drawing.Size(472, 445)
            Me.Controls.Add(Me.StatusBar)
            Me.Controls.Add(Me.TimerLabel)
            Me.Controls.Add(Me.ReadTimeUpDown)
            Me.Controls.Add(Me.ReadListBox)
            Me.Controls.Add(Me.MultiReadCheckBox)
            Me.Controls.Add(Me.WriteLabel)
            Me.Controls.Add(Me.ReadStatLabel)
            Me.Controls.Add(Me.CloseLabel)
            Me.Controls.Add(Me.ReadLabel)
            Me.Controls.Add(Me.CloseButton)
            Me.Controls.Add(Me.ReadButton)
            Me.Controls.Add(Me.WriteStatLabel)
            Me.Controls.Add(Me.WriteButton)
            Me.Controls.Add(Me.StatusLabel)
            Me.Controls.Add(Me.StatusButton)
            Me.Controls.Add(Me.InitLabel)
            Me.Controls.Add(Me.InitButton)
            Me.Controls.Add(Me.VersionLabel)
            Me.Controls.Add(Me.VersionInfoButton)
            Me.Name = "Form1"
            Me.Text = "PCAN Light USB - VB.Net DEMO (c) PEAK-System Technik GmbH"
            CType(Me.ReadTimeUpDown, System.ComponentModel.ISupportInitialize).EndInit()
            Me.ResumeLayout(False)

        End Sub

#End Region

        Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles VersionInfoButton.Click
            Dim buff As StringBuilder = New StringBuilder(256)

            Dim res As Int32 = PCAN_usb.VersionInfo(buff)
            If res = PCAN_usb.CAN_ERR_OK Then

                'Versionsinfo anzeigen
                VersionLabel.Text = buff.ToString()
            Else

                'Fehler anzeigen
                VersionLabel.Text = ErrToText(res)
            End If

        End Sub


        Private Sub InitButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles InitButton.Click

            'USB Hardware mit 1MBit/s initialisieren, Extended frames
            Dim res As Int32 = PCAN_usb.init(PCAN_usb.CAN_BAUD_1M, PCAN_usb.CAN_INIT_TYPE_EX)

            InitLabel.Text = ErrToText(res)  'Ergebnis anzeigen

            If res = PCAN_usb.CAN_ERR_OK Then

                StatusBar.Text = "HARDWARE IS INITIALIZED     BAUDRATE: 1MBit/s   FRAME: EXTENDED FRAME"

                InitButton.Enabled = False
                StatusButton.Enabled = True
                WriteButton.Enabled = True
                WriteLabel.Visible = True
                ReadButton.Enabled = True
                ReadLabel.Visible = True
                CloseButton.Enabled = True
                CloseLabel.Text = ""
                MultiReadCheckBox.Enabled = True
                ReadTimeUpDown.Enabled = True

                'ListBox saeubern
                ReadListBox.Items.Clear()
                ReadListBox.Items.Add("###############")
                ReadListBox.Items.Add("  No CAN messages")
                ReadListBox.Items.Add("###############")

            End If

        End Sub


        Private Sub StatusButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles StatusButton.Click

            'Status abfragen
            Dim res As Int32 = PCAN_usb.Status()
            StatusLabel.Text = ErrToText(res)

        End Sub


        Private Sub WriteButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles WriteButton.Click

            '#############################
            '##  Eine CAN-Nachricht senden
            '#############################

            'Initialisierung der Messagestruktur
            Dim msg As New PCAN_usb.TCANMsg()

            'Daten-Array initialisieren
            ReDim msg.DATA(7)

            'Testnachricht zusammenbauen
            msg.ID = &H100
            msg.LEN = 8
            msg.MSGTYPE = 0

            msg.DATA(0) = &H12
            msg.DATA(1) = &H34
            msg.DATA(2) = &H56
            msg.DATA(3) = &H78
            msg.DATA(4) = &H90
            msg.DATA(5) = &HAB
            msg.DATA(6) = &HCD
            msg.DATA(7) = &HEF

            'CAN-Nachricht versenden
            Dim res As Integer = PCAN_usb.Write(msg)

            'Ergebnis anzeigen
            WriteStatLabel.Text = ErrToText(res)

        End Sub


        Private Sub ReadButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ReadButton.Click
            '#######################
            '##  CAN-Nachricht lesen
            '#######################

            'Variablendeklaration
            Dim datstr As String = ""
            Dim str As String = ""
            Dim i As Integer

            'Initialisierung der Messagestruktur
            Dim msg As PCAN_usb.TCANMsg = New PCAN_usb.TCANMsg()

            'Datenarray inítialisieren
            ReDim msg.DATA(7)

            'CAN-Nachricht aus der Queue holen/lesen
            Dim res As Integer = PCAN_usb.Read(msg)

            'CAN-Nachrichtenkennung (ID) und -länge (LEN) als String ausgeben
            If res = PCAN_usb.CAN_ERR_OK Then
                str = "ID: " & msg.ID.ToString("X3") & "   LEN: " & msg.LEN.ToString() & "   DATA: "

                'Data Frame als String ausgeben
                If ((msg.MSGTYPE And PCAN_usb.MSGTYPE_RTR) = 0) Then  'Data frame
                    For i = 0 To (msg.LEN - 1) Step 1
                        datstr += msg.DATA(i).ToString("X2") + " "
                    Next
                Else
                    datstr = "RTR"
                End If
            End If

            ReadLabel.Text = str + " " + datstr
            ReadStatLabel.Text = ErrToText(res)

        End Sub


        Private Sub CloseButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CloseButton.Click

            If MultiReadCheckBox.Checked = True Then
                MultiReadCheckBox.Checked = False
                MultiReadCheckBox_CheckedChanged(sender, e)
            End If

            'USB-Hardware schliessen
            Dim res As Int32 = PCAN_usb.Close()
            CloseLabel.Text = ErrToText(res)

            'Funktionen deaktivieren
            InitButton.Enabled = True
            InitLabel.Text = ""
            StatusButton.Enabled = False
            StatusLabel.Text = ""
            WriteButton.Enabled = False
            WriteLabel.Visible = False
            WriteStatLabel.Text = ""
            ReadButton.Enabled = False
            ReadLabel.Text = ""
            ReadStatLabel.Text = ""
            MultiReadCheckBox.Enabled = False
            ReadTimeUpDown.Enabled = False
            CloseButton.Enabled = False
            StatusBar.Text = "HARDWARE IS NOT INITIALIZED"
        End Sub


        Public Function ErrToText(ByVal err As Int32)

            If err = PCAN_usb.CAN_ERR_OK Then
                Return "OK"
            End If

            Dim str As String = ""

            If (err And PCAN_usb.CAN_ERR_XMTFULL) <> 0 Then
                str += "XMTFULL "
            ElseIf (err And PCAN_usb.CAN_ERR_OVERRUN) <> 0 Then
                str += "OVERRUN"
            ElseIf (err And PCAN_usb.CAN_ERR_BUSLIGHT) <> 0 Then
                str += "BUSLIGHT"
            ElseIf (err And PCAN_usb.CAN_ERR_BUSHEAVY) <> 0 Then
                str += "BUSHEAVY"
            ElseIf (err And PCAN_usb.CAN_ERR_BUSOFF) <> 0 Then
                str += "BUSOFF"
            ElseIf (err And PCAN_usb.CAN_ERR_QRCVEMPTY) <> 0 Then
                str += "QRCVEMPTY"
            ElseIf (err And PCAN_usb.CAN_ERR_QOVERRUN) <> 0 Then
                str += "QOVERRUN"
            ElseIf (err And PCAN_usb.CAN_ERR_QXMTFULL) <> 0 Then
                str += "QXMTFULL"
            ElseIf (err And PCAN_usb.CAN_ERR_REGTEST) <> 0 Then
                str += "REGTEST"
            ElseIf (err And PCAN_usb.CAN_ERR_NOVXD) <> 0 Then
                str += "NOVXD"
            ElseIf (err And PCAN_usb.CAN_ERR_RESOURCE) <> 0 Then
                str += "RESOURCE"
            End If

            'Unkown Error - please check the USB-hardware connection
            If str = "" Then
                str += "Unknown ERROR - Please check the PCAN-USB hardware connection"
            End If

            Return str

        End Function

        Private Sub MultiReadCheckBox_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MultiReadCheckBox.CheckedChanged

            If MultiReadCheckBox.Checked = True Then
                Timer1.Enabled = True
                ReadListBox.Items.Add("Timer is started, intervall: " + Timer1.Interval.ToString() + " ms")
            ElseIf MultiReadCheckBox.Checked = False Then
                Timer1.Enabled = False
                ReadListBox.Items.Add("Timer ís stoped")
            End If

        End Sub

        Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick

            Dim msg As PCAN_usb.TCANMsg = New PCAN_usb.TCANMsg()

            'Datenarray inítialisieren
            ReDim msg.DATA(7)

            Dim str As String
            Dim i As Integer
            Dim res As Int32

            Do
                'Nachricht aus der Queue lesen
                res = PCAN_usb.Read(msg)

                str = ""

                'Nachricht auswerten
                If res = PCAN_usb.CAN_ERR_OK Then  'wenn Nachricht OK

                    ' Nachricht als String formatieren und ausgeben
                    str = "ID: " + msg.ID.ToString("X3") + "   LEN: " + msg.LEN.ToString()

                    If (msg.MSGTYPE And PCAN_usb.MSGTYPE_RTR) = 0 Then 'Data Frame

                        str += "   DATA: "

                        For i = 0 To msg.LEN - 1 Step +1
                            str += msg.DATA(i).ToString("X2") + " "
                        Next

                    ElseIf (msg.MSGTYPE & PCAN_usb.MSGTYPE_RTR) = 1 Then 'Remote Request RTR

                        str += "   RTR"

                    End If

                    ReadListBox.Items.Add(str.ToString())
                    ReadListBox.SetSelected(ReadListBox.Items.Count - 1, True)

                ElseIf res <> PCAN_usb.CAN_ERR_OK And res <> PCAN_usb.CAN_ERR_QRCVEMPTY Then  'wenn Fehlermeldung
                    ReadListBox.Items.Add(ErrToText(res))
                End If

            Loop While res <> PCAN_usb.CAN_ERR_QRCVEMPTY 'solange Nachrichten aus der queue holen bis diese leer ist.

        End Sub

        Private Sub ReadTimeUpDown_ValueChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ReadTimeUpDown.ValueChanged

            Timer1.Interval = CInt(ReadTimeUpDown.Value)

        End Sub
    End Class
End Namespace
