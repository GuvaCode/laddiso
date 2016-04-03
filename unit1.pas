{%RunCommand $MakeExe(bin/$(EdFile))}
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
    About: TMenuItem;
    DDExecuteOutput: TMemo;
    StepsPanel: TPanel;
    USBComboBox: TComboBox;
    USBLabel: TLabel;
    USBRefreshButton: TButton;
    USBStepLabel: TLabel;
    procedure AboutClick(Sender: TObject);
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
  shellProcess: TProcess;

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
  DDExecuteOutput.Lines.Clear;

  shellProcess := TProcess.Create(nil);

  shellProcess.Executable := '/bin/sh';
  shellProcess.Parameters.Add('-c');
  shellProcess.Parameters.Add(DDEdit.Text);

  shellProcess.Options := shellProcess.Options
                       + [poUsePipes, poStderrToOutPut{, poWaitOnExit}];
  shellProcess.Execute;

  //DDExecuteOutput.Lines.LoadFromStream(shellProcess.Stderr);
  DDExecuteOutput.Lines.LoadFromStream(shellProcess.Output);

  shellProcess.Free;
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
  ShowMessage('Laddiso'
               + AnsiChar(#10)
               + '====='
               + AnsiChar(#10)
               + 'A simple Lazarus/Free Pascal GUI front'
               + ' for the "dd" command on GNU/Linux,'
               + ' for writing ".iso" files to USB devices.'
               + AnsiChar(#10) + AnsiChar(#10)
               + 'GitHub'
               + AnsiChar(#10)
               + '====='
               + AnsiChar(#10)
               + 'https://github.com/itmitica/laddiso'
               + AnsiChar(#10) + AnsiChar(#10)
               + 'Author'
               + AnsiChar(#10)
               + '====='
               + AnsiChar(#10)
               + 'Dumitru "Mitică" UNGUREANU'
               + AnsiChar(#10)
               + 'http://itmitica.github.io/'
               + AnsiChar(#10)
               + 'itmitica@gmail.com'
               + AnsiChar(#10) + AnsiChar(#10)
               + 'Version'
               + AnsiChar(#10)
               + '====='
               + AnsiChar(#10)
               + 'Laddiso v1.0,'
               + AnsiChar(#10)
               + 'February 15, 2016'
  );
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
  DDEdit.Text := 'pv -Wfn -s $(wc -c < '
               + ISOEdit.Text
               + ') '
               + ISOEdit.Text
               + ' | pkexec dd of=/dev/'
               + usbPart
               + ' bs=1M iflag=fullblock oflag=dsync,direct conv=notrunc,noerror';
end;

end.

