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
    MainMenu: TMainMenu;
    HelpMain: TMenuItem;
    Help: TMenuItem;
    About: TMenuItem;
    Memo1: TMemo;
    Memo2: TMemo;
    StepsPanel: TPanel;
    USBComboBox: TComboBox;
    USBLabel: TLabel;
    USBrefreshButton: TButton;
    USBStepLabel: TLabel;
    procedure DDExecuteButtonClick(Sender: TObject);
    procedure ISOBrowseButtonClick(Sender: TObject);
    procedure USBComboBoxSelect(Sender: TObject);
    procedure USBrefreshButtonClick(Sender: TObject);
    procedure DDCommand(Sender: TObject);
    procedure ShellComm(Sender: TObject);
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
begin
  ShellComm(nil);
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

procedure TMainForm.USBrefreshButtonClick(Sender: TObject);
var
  cArgs: String;
  ShellProcess : TProcess;
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

  ShellProcess := TProcess.Create(nil);

  ShellProcess.Executable := '/bin/sh';
  ShellProcess.Parameters.Add('-c');
  ShellProcess.Parameters.Add(cArgs);
  ShellProcess.Options := ShellProcess.Options + [poWaitOnExit, poUsePipes];

  ShellProcess.Execute;

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

  ShellProcess.Free;

end;

procedure TMainForm.DDCommand(Sender: TObject);
begin
  DDEdit.Text := 'dd if='
               + ISOEdit.Text
               + ' of=/dev/'
               + usbPart;
               //+ '; sync';
end;

procedure TMainForm.ShellComm(Sender: TObject);
var
  hprocess: TProcess;
  //sPass: String;
  //command: String;
begin
  //sPass := 'password';
  //command := 'echo ' + sPass  + ' | ' + DDEdit.Text;

  ShowMessage(command);

  hProcess := TProcess.Create(nil);

  hProcess.Executable := '/bin/sh';
  hprocess.Parameters.Add('-c');
  hprocess.Parameters.Add(DDEdit.Text);

  hProcess.Options := hProcess.Options + [poWaitOnExit, poUsePipes];
  hProcess.Execute;

  //while hProcess.Running do
  //  begin
      memo1.Lines.LoadFromStream(hprocess.Output);
      memo2.Lines.LoadFromStream(hProcess.Stderr);
    //end;

  hProcess.Free;

 end;

end.

