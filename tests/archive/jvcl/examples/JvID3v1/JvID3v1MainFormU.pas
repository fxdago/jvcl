unit JvID3v1MainFormU;
{$I JVCL.INC}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, JvComponent, StdCtrls, Mask, JvToolEdit,
  JvDragDrop, JvId3v1, ComCtrls, ToolWin, ActnList, ImgList, JvJVCLAbout,
  JvBaseDlg, JvTipOfDay, JvBalloonHint;

type
  TJvID3v1MainForm = class(TForm)
    JvFilenameEdit1: TJvFilenameEdit;
    JvDragDrop1: TJvDragDrop;
    edtTitle: TEdit;
    JvId3v11: TJvId3v1;
    edtAlbum: TEdit;
    edtArtist: TEdit;
    edtYear: TEdit;
    edtComment: TEdit;
    cmbGenre: TComboBox;
    lblTitle: TLabel;
    lblArtist: TLabel;
    lblAlbum: TLabel;
    lblYear: TLabel;
    lblComment: TLabel;
    lblGenre: TLabel;
    ActionList1: TActionList;
    actSave: TAction;
    actRefresh: TAction;
    actErase: TAction;
    actExit: TAction;
    actOnTop: TAction;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    lblHasTag: TLabel;
    JvTipOfDay1: TJvTipOfDay;
    JvJVCLAboutComponent1: TJvJVCLAboutComponent;
    actAbout: TAction;
    ToolButton6: TToolButton;
    JvBalloonHint1: TJvBalloonHint;
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint;
      Value: TStringList);
    procedure actSaveExecute(Sender: TObject);
    procedure actEraseExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actOnTopExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvFilenameEdit1KeyPress(Sender: TObject; var Key: Char);
    procedure JvFilenameEdit1AfterDialog(Sender: TObject; var Name: string;
      var Action: Boolean);
    procedure actAboutExecute(Sender: TObject);
  public
    procedure ChangeFileNameTo(S: string);
    procedure FillGenres(Strings: TStrings);
    procedure UpdateCtrls;
    procedure UpdateCaption;
  end;

var
  JvID3v1MainForm: TJvID3v1MainForm;

implementation
{$IFDEF COMPILER6_UP}
uses
  DateUtils;
{$ENDIF}  

{$R *.dfm}

{$IFNDEF COMPILER6_UP}
function AnsiDeQuotedStr(S:string;Quote:Char):string;
var P:PChar;
begin
  P := PChar(S);
  Result := AnsiExtractQuotedStr(P,Quote);
end;
{$ENDIF}

procedure TJvID3v1MainForm.ChangeFileNameTo(S: string);
begin
  JvFilenameEdit1.Text := S;
  S := AnsiDeQuotedStr(S, '"');
  JvFilenameEdit1.Hint := S;
  JvId3v11.FileName := S;
  UpdateCtrls;
  UpdateCaption;
end;

procedure TJvID3v1MainForm.FillGenres(Strings: TStrings);
var
  Genre: TGenre;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    for Genre := Low(TGenre) to High(TGenre) do
      Strings.AddObject(JvId3v11.GenreToString(Genre), TObject(Genre));
  finally
    Strings.EndUpdate;
  end;
end;

procedure TJvID3v1MainForm.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;
  Value: TStringList);
begin
  if Value.Count > 0 then
    ChangeFileNameTo(Value[0]);
end;

procedure TJvID3v1MainForm.actSaveExecute(Sender: TObject);
begin
  if JvId3v11.FileName = '' then
    JvBalloonHint1.ActivateHint(JvFilenameEdit1, 'First select a mp3 file', ikError, 'Error', 5000)
  else
  begin
    JvId3v11.SongName := edtTitle.Text;
    JvId3v11.Artist := edtArtist.Text;
    JvId3v11.Album := edtAlbum.Text;
    JvId3v11.Year := edtYear.Text;
    with cmbGenre do
      JvId3v11.Genre := TGenre(Items.Objects[ItemIndex]);
    JvId3v11.Comment := edtComment.Text;
    JvId3v11.WriteTag;
    UpdateCaption;
  end;
end;

procedure TJvID3v1MainForm.actEraseExecute(Sender: TObject);
begin
  if JvId3v11.FileName = '' then
    JvBalloonHint1.ActivateHint(JvFilenameEdit1, 'First select a mp3 file', ikError, 'Error', 5000)
  else
  begin
    JvId3v11.RemoveTag;
    UpdateCtrls;
    UpdateCaption;
  end;
end;

procedure TJvID3v1MainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TJvID3v1MainForm.actRefreshExecute(Sender: TObject);
begin
  if JvId3v11.FileName = '' then
    JvBalloonHint1.ActivateHint(JvFilenameEdit1, 'First select a mp3 file', ikError, 'Error', 5000)
  else
    ChangeFileNameTo(JvId3v11.FileName);
end;

procedure TJvID3v1MainForm.actOnTopExecute(Sender: TObject);
const
  CStyle: array[Boolean] of TFormStyle = (fsNormal, fsStayOnTop);
begin
  JvDragDrop1.AcceptDrag := False;
  actOnTop.Checked := not actOnTop.Checked;
  FormStyle := CStyle[actOnTop.Checked];
  JvDragDrop1.AcceptDrag := True;
end;

procedure TJvID3v1MainForm.FormCreate(Sender: TObject);
begin
  { This is put in the OnCreate and not in the OnShow event, because we change
    Form1.FormStyle at run-time that will trigger the OnShow event }
  FillGenres(cmbGenre.Items);
  UpdateCaption;
end;

procedure TJvID3v1MainForm.JvFilenameEdit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if JvFilenameEdit1.Text = '' then
      JvBalloonHint1.ActivateHint(JvFilenameEdit1, 'Empty strings are no file names', ikError, 'Error', 5000)
    else
      ChangeFileNameTo(JvFilenameEdit1.Text);
  end;
end;

procedure TJvID3v1MainForm.JvFilenameEdit1AfterDialog(Sender: TObject;
  var Name: string; var Action: Boolean);
begin
  if Action then
    ChangeFileNameTo(Name);
end;

procedure TJvID3v1MainForm.UpdateCaption;
const
  CHasTagStr: array[Boolean] of string = ('No tag', 'Has Tag');
  CHasTagColor: array[Boolean] of TColor = (clRed, clBlack);
var
  HasTag: Boolean;
begin
  if JvId3v11.FileName > '' then
  begin
    { Store TagPresent in variabele to prevent double checks whether the file
      has a tag }
    HasTag := JvId3v11.TagPresent;
    lblHasTag.Font.Color := CHasTagColor[HasTag];
    lblHasTag.Caption := CHasTagStr[HasTag];
  end
  else
    lblHasTag.Caption := '';
end;

procedure TJvID3v1MainForm.UpdateCtrls;
begin
  edtTitle.Text := JvId3v11.SongName;
  edtAlbum.Text := JvId3v11.Album;
  edtArtist.Text := JvId3v11.Artist;
  edtYear.Text := JvId3v11.Year;
  edtComment.Text := JvId3v11.Comment;
  cmbGenre.ItemIndex := cmbGenre.Items.IndexOfObject(TObject(JvId3v11.Genre));
end;

procedure TJvID3v1MainForm.actAboutExecute(Sender: TObject);
begin
  JvJVCLAboutComponent1.Execute;
end;

end.

