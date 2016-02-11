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
    ISOFind: TOpenDialog;
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

procedure TMainForm.USBrefreshButtonClick(Sender: TObject);
var
  command: String;
  AProcess : TProcess;
  AStringList: TStringList;
  output: String;
begin
  command :=
    Trim('ls -lQ /dev/disk/by-id                    ') +
    Trim('  | sed -n ''/usb/p''                     ') +
    Trim('  | sed ''/sd.[0-9]/d''                   ') +
    Trim('  | sed ''s/[^"]* //''                    ') +
    Trim('  | sed ''s/\/dev\/disk\/by-id\/usb-//g'' ') +
    Trim('  | sed ''s/\..\/..\///g''                ') +
    Trim('  | sed ''s/_[0-9].*:0//g''               ') +
    Trim('  | sed ''s/_/ /g''                       ') ;

  AProcess := TProcess.Create(nil);
  AStringList := TStringList.Create;
  AProcess.CommandLine := '/bin/sh -c  "ls -lQ /dev/disk/by-id/usb*"';
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

  AProcess.Execute;

  AStringList.LoadFromStream(AProcess.Output);
  output := AStringList.Text;
  ShowMessage(output);

  AStringList.Free;
  AProcess.Free;
end;

end.

