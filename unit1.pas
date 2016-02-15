unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, Process, StrUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    DDEdit: TEdit;
    DDExecuteButton: TButton;
    DDLabel: TLabel;
    DDStepLabel: TLabel;
    ISOBrowseButton: TButton;
    ISOEdit: TEdit;
    ISOLabel: TLabel;
    ISOStepLabel: TLabel;
    TermOutput: TLabel;
    MainMenu: TMainMenu;
    HelpMain: TMenuItem;
    Help: TMenuItem;
    About: TMenuItem;
    DDExecuteOutput: TMemo;
    StepsPanel: TPanel;
    USBComboBox: TComboBox;
    USBLabel: TLabel;
    USBRefreshButton: TButton;
    USBStepLabel: TLabel;
    procedure DDExecuteButtonClick(Sender: TObject);
    procedure ISOBrowseButtonClick(Sender: TObject);
    procedure USBComboBoxSelect(Sender: TObject);
    procedure USBRefreshButtonClick(Sender: TObject);
    procedure DDCommand(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;
  usbPart : ShortString;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.ISOBrowseButtonClick(Sender: TObject);
var
  ISOFind : TOpenDialog;
begin
  ISOFind := TOpenDialog.Create(nil);

  ISOFind.Title := 'Open existing .iso file';
  ISOFind.InitialDir := GetUserDir() + '/Downloads';
  ISOFind.Filter := 'ISO files|*.iso';
  ISOFind.FilterIndex := 1;

  if ISOFind.Execute = true then
  begin
    ISOEdit.Text := ISOFind.Filename;
    DDCommand(nil);
  end;

  ISOFind.Free;
end;

procedure TMainForm.DDExecuteButtonClick(Sender: TObject);
var
  shellProcess: TProcess;
  sPass: String;
  cArgs: String;
 begin
   sPass := '';
   cArgs := '';

   if InputQuery ('Authentication required',
                  'Enter sudo password:',
                  TRUE,
                  sPass) then
      if MessageDlg ('Confirm',
                     'Execute this command?'
                       + AnsiChar(#10) + AnsiChar(#10)
                       + '"' + DDEdit.Text + '"'
                       + AnsiChar(#10) + AnsiChar(#10)
                       + AnsiChar(#10) + AnsiChar(#10)
                       + 'Wait for this message window to disappear.'
                       + ' If you press "Yes" it may take a while.'
                       + AnsiChar(#10) + AnsiChar(#10)
                       + 'Verify in the execution results'
                       + ' area to see if the command completed successfully.'
                       + ' Guide yourself using the LED notification light'
                       + ' on the USB device, if it exists. When flashing stops'
                       + ', the copying process is finalized.',
                       mtConfirmation,
                     [mbYes, mbNo],
                     0
                    ) = mrYes then
     begin
       cArgs := 'echo ' + sPass  + ' | ' + DDEdit.Text + '; sync';
       DDExecuteOutput.Lines.Clear;

       shellProcess := TProcess.Create(nil);

       shellProcess.Executable := '/bin/sh';
       shellProcess.Parameters.Add('-c');
       shellProcess.Parameters.Add(cArgs);

       shellProcess.Options := shellProcess.Options
                             + [poWaitOnExit, poUsePipes];
       shellProcess.Execute;

       DDExecuteOutput.Lines.LoadFromStream(shellProcess.Stderr);

       shellProcess.Free;
    end;

end;

procedure TMainForm.USBComboBoxSelect(Sender: TObject);
var
  str : ShortString;

  strLen,
  charPos: Integer;

begin
  str := USBCombobox.Text;
  strLen := Length(str);
  charPos := PosEx('>', str);

  usbPart :=
    Trim(
      DelChars(
        AnsiMidStr(
          str,
          charPos + 1,
          strLen - charPos
        ),
        '"'
      )
    );

  DDCommand(nil);
end;

procedure TMainForm.USBRefreshButtonClick(Sender: TObject);
var
  cArgs: String;
  shellProcess : TProcess;
begin
  cArgs :=
    Trim('ls -lQ /dev/disk/by-id        ') +
    Trim('  |sed -n ''/usb/p''          ') +
    Trim('  |sed ''/sd.[0-9]/d''        ') +
    Trim('  |sed ''s/[^\""]* //''       ') +
    Trim('  |sed ''s/\usb-//g''         ') +
    Trim('  |sed ''s/\..\/..\///g''     ') +
    Trim('  |sed ''s/_[0-9].*:0//g''    ') +
    Trim('  |sed ''s/_/ /g''            ');

  shellProcess := TProcess.Create(nil);

  shellProcess.Executable := '/bin/sh';
  shellProcess.Parameters.Add('-c');
  shellProcess.Parameters.Add(cArgs);
  shellProcess.Options := shellProcess.Options + [poWaitOnExit, poUsePipes];

  shellProcess.Execute;

  USBComboBox.Items.LoadFromStream(ShellProcess.Output);

  if USBComboBox.Items.Count > 0 then
    begin
      USBComboBox.ItemIndex := 0;
      USBComboBox.SetFocus;

      if USBComboBox.Items.Count > 1 then
        begin
          USBComboBox.DroppedDown := true;
          USBComboBoxSelect(nil);
        end;

    end;

  shellProcess.Free;

end;

procedure TMainForm.DDCommand(Sender: TObject);
begin
  DDEdit.Text := 'sudo -S dd if='
               + ISOEdit.Text
               + ' of=/dev/'
               + usbPart;

end;

end.

