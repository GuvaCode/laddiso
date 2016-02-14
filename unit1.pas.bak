unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, Process;

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
    procedure HelpMainClick(Sender: TObject);
    procedure ISOBrowseButtonClick(Sender: TObject);
    procedure USBrefreshButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.HelpMainClick(Sender: TObject);
begin

end;

procedure TMainForm.ISOBrowseButtonClick(Sender: TObject);
var
  ISOFind : TOpenDialog;
begin
  ISOFind := TOpenDialog.Create(nil);

  ISOFind.Title := 'Open existing .iso file';
  ISOFind.InitialDir := '/home/';
  ISOFind.Filter := 'ISO files|*.iso';
  ISOFind.FilterIndex := 1;

  if ISOFind.Execute = true then
    ISOEdit.Text := ISOFind.Filename;

  ISOFind.Free;
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

  USBCombobox.Items.LoadFromStream(ShellProcess.Output);

  if USBCombobox.Items.Count > 0 then
    begin
      USBCombobox.ItemIndex := 0;
      USBCombobox.SetFocus;

      if USBCombobox.Items.Count > 1 then
        USBCombobox.DroppedDown := true;

    end;

  ShellProcess.Free;

end;

end.

