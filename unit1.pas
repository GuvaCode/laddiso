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
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;
  usb_part : ShortString;

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
  command: String;
  ShellProcess : TProcess;
begin
  command :=
    Trim('/bin/sh -c "    ') +
    DDEdit.Text              +
    Trim('"               ');

  //ShellProcess := TProcess.Create(nil);
  //
  //ShellProcess.CommandLine := command;
  //ShellProcess.Options := ShellProcess.Options + [poWaitOnExit, poUsePipes];
  //
  //ShellProcess.Execute;
  //
  //ShellProcess.Free;

  ShowMessage(command);
end;

procedure TMainForm.USBComboBoxSelect(Sender: TObject);
var
  str : ShortString;

  str_len,
  char_pos: Integer;

begin
  str := USBCombobox.Text;
  str_len := Length(str);
  char_pos := PosEx('>', str);

  usb_part :=
    Trim(
      DelChars(
        AnsiMidStr(
          str,
          char_pos + 1,
          str_len - char_pos
        ),
        '"'
      )
    );

  DDCommand(nil);
end;

procedure TMainForm.USBrefreshButtonClick(Sender: TObject);
var
  command: String;
  ShellProcess : TProcess;
begin
  command :=
    Trim('/bin/sh -c "                  ') +
    Trim('ls -lQ /dev/disk/by-id        ') +
    Trim('  |sed -n ''/usb/p''          ') +
    Trim('  |sed ''/sd.[0-9]/d''        ') +
    Trim('  |sed ''s/[^\""]* //''       ') +
    Trim('  |sed ''s/\usb-//g''         ') +
    Trim('  |sed ''s/\..\/..\///g''     ') +
    Trim('  |sed ''s/_[0-9].*:0//g''    ') +
    Trim('  |sed ''s/_/ /g''            ') +
    Trim('"                             ');

  ShellProcess := TProcess.Create(nil);

  ShellProcess.CommandLine := command;
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
  DDEdit.Text := 'sudo dd if='
               + ISOEdit.Text
               + ' of=/dev/'
               + usb_part
               + '; sync';
end;

end.

