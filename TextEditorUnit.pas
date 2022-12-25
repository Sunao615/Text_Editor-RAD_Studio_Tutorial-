unit TextEditorUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Menus,
  System.Actions, FMX.ActnList, FMX.DialogService.Sync;

type
  TTextEditorForm = class(TForm)
    ActionList: TActionList;
    MainMenu: TMainMenu;
    StatusBar: TStatusBar;
    Editor: TMemo;
    SaveFileDialog: TSaveDialog;
    OpenFileDialog: TOpenDialog;
    NewAction: TAction;
    OpenAction: TAction;
    SaveAction: TAction;
    SaveAsAction: TAction;
    ExitAction: TAction;
    CutAction: TAction;
    PasteAction: TAction;
    SelectAllAction: TAction;
    UndoAction: TAction;
    DeleteAction: TAction;
    WordWrapAction: TAction;
    FileMenu: TMenuItem;
    EditMenu: TMenuItem;
    FormatMenu: TMenuItem;
    NewMenu: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    SaveAsMenu: TMenuItem;
    ExitMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    CopyMenu: TMenuItem;
    PasteMenu: TMenuItem;
    SelectAllMenu: TMenuItem;
    UndoMenu: TMenuItem;
    WordWrapMenu: TMenuItem;
    LineNumber: TLabel;
    ColumnNumber: TLabel;
    LIneCount: TLabel;
    CopyAction: TAction;
    CutMenu: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure EditorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure EditorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure NewActionExecute(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure SaveAsActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure CutActionExecute(Sender: TObject);
    procedure PasteActionExecute(Sender: TObject);
    procedure CopyActionExecute(Sender: TObject);
    procedure SelectAllActionExecute(Sender: TObject);
    procedure UndoActionExecute(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
    procedure WordWrapActionExecute(Sender: TObject);
  private
    { private éŒ¾ }
    CurrentFile : String;
    procedure UpdateStatusBar;
  public
    { public éŒ¾ }
  end;

var
  TextEditorForm: TTextEditorForm;

implementation

{$R *.fmx}

{ TTextEditorForm }

//Edit > Copy
procedure TTextEditorForm.CopyActionExecute(Sender: TObject);
begin
  Editor.CopyToClipboard
end;

//Edit > Cut
procedure TTextEditorForm.CutActionExecute(Sender: TObject);
begin
  Editor.CutToClipboard;
  UpdateStatusBar;
end;

//Edit > Delete
procedure TTextEditorForm.DeleteActionExecute(Sender: TObject);
begin
  if Editor.SelLength > 0 then
  begin
    Editor.DeleteSelection;
  end
  else
  begin
    Editor.DeleteFrom(Editor.CaretPosition, 1, [TDeleteOption.MoveCaret]);
    UpdateStatusBar;
  end;
end;

procedure TTextEditorForm.EditorKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  UpdateStatusBar;
end;

procedure TTextEditorForm.EditorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  UpdateStatusBar;
end;

//File > Exit
procedure TTextEditorForm.ExitActionExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TTextEditorForm.FormCreate(Sender: TObject);
begin
  Editor.Lines.Add('');
  UpdateStatusBar;
end;

procedure TTextEditorForm.NewActionExecute(Sender: TObject);
var
  UserResponse : TModalResult;
begin
  //ƒƒ‚‚ª‹ó‚Å‚È‚¢‚±‚Æ‚ðŠm”F‚·‚é.
  if not Editor.Text.IsEmpty then
  begin
    UserResponse := TDialogServiceSync.MessageDialog(
      'This will the clear the current document. Do you want to continue?',
      TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0);
    if UserResponse = mrYes then
    begin
      Editor.Text := '';
      Editor.Lines.Add(''); //ƒƒ‚‚Ìline count‚ð1‚Å‰Šú‰»
      UpdateStatusBar;
      CurrentFile := ''; //Save‚³‚ê‚é‚Ü‚ÅV‹Kƒtƒ@ƒCƒ‹–¼‚ÍŠi”[‚³‚ê‚È‚¢
    end;
  end;
end;

//File > Open
procedure TTextEditorForm.OpenActionExecute(Sender: TObject);
var
  FileName : String;
begin
  if OpenFileDialog.Execute = True then
  begin
    FileName := OpenFileDialog.FileName;
    if FileExists(FileName) then
    begin
      Editor.Lines.LoadFromFile(FileName);
      CurrentFile := FileName;
      Caption := 'Text Editor - ' + ExtractFileName(FileName);
    end;
  end;
end;

//Edit > Paste
procedure TTextEditorForm.PasteActionExecute(Sender: TObject);
begin
  Editor.PasteFromClipboard;
  UpdateStatusBar;
end;

//File > Save
procedure TTextEditorForm.SaveActionExecute(Sender: TObject);
begin
  if CurrentFile = '' then
  begin
    SaveAsAction.Text;
  end
  else
  begin
    Editor.Lines.SaveToFile(CurrentFile);
  end;
end;

//File > SaveAs
procedure TTextEditorForm.SaveAsActionExecute(Sender: TObject);
var
  FileName : String;
  UserResponse : TModalResult;
begin
  if SaveFileDialog.Execute = True then
  begin
    FileName := SaveFileDialog.FileName;
    if FileExists(FileName) then
    begin
      UserResponse := TDialogServiceSync.MessageDialog(
      'File already exists. Do you want to overwrite?',
      TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0);
      if UserResponse = mrNo then
      begin
        Exit;
      end;
      Editor.Lines.SaveToFile(FileName);
      CurrentFile := FileName;
      Caption := 'Text Editor - ' + ExtractFileName(FileName);
    end;
  end;
end;

//Edit > Select All
procedure TTextEditorForm.SelectAllActionExecute(Sender: TObject);
begin
  Editor.SelectAll;
  UpdateStatusBar;
end;

//Edit > Undo
procedure TTextEditorForm.UndoActionExecute(Sender: TObject);
begin
  Editor.UnDo;
  UpdateStatusBar;
end;

procedure TTextEditorForm.UpdateStatusBar;
begin
  LineNumber.Text := 'L: ' + (Editor.CaretPosition.Line + 1).ToString;
  ColumnNumber.Text := 'C: ' + (Editor.CaretPosition.Pos + 1).ToString;
  LineCount.Text := 'Line: ' + Editor.Lines.Count.ToString;
end;

//Format > Word Wrap
procedure TTextEditorForm.WordWrapActionExecute(Sender: TObject);
begin
  Editor.WordWrap := not Editor.WordWrap;
  WordWrapAction.Checked := Editor.WordWrap;
  UpdateStatusBar;
end;

end.
