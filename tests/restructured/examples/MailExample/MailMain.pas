unit MailMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JvMail, ExtCtrls, ComCtrls, StdCtrls, JvDialogs, JvComponent;

type
  TMainForm = class(TForm)
    JvMail1: TJvMail;
    ClientTypeGroupBox: TGroupBox;
    AutomaticRadioBtn: TRadioButton;
    MapiRadioBtn: TRadioButton;
    DirectRadioBtn: TRadioButton;
    ClientsListView: TListView;
    ClientLabel: TLabel;
    ToEdit: TEdit;
    Label1: TLabel;
    SubjectEdit: TEdit;
    Label2: TLabel;
    BodyEdit: TRichEdit;
    SendBtn: TButton;
    Label3: TLabel;
    AttachmentMemo: TMemo;
    Label4: TLabel;
    AttachBtn: TButton;
    JvOpenDialog1: TJvOpenDialog;
    CcEdit: TEdit;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ClientsListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure AutomaticRadioBtnClick(Sender: TObject);
    procedure ClientsListViewCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SendBtnClick(Sender: TObject);
    procedure AttachBtnClick(Sender: TObject);
  private
    procedure BuildClientList;
    procedure UpdateClientName;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

uses
  JclMapi;

procedure TMainForm.BuildClientList;
var
  I: Integer;
begin
  ClientsListView.Items.BeginUpdate;
  ClientsListView.Items.Clear;
  with JvMail1.SimpleMAPI do
  begin
    for I := 0 to ClientCount - 1 do
      with ClientsListView.Items.Add do
      begin
        Caption := Clients[I].RegKeyName;
        Data := Pointer(Clients[I].Valid);
        SubItems.Add(Clients[I].ClientName);
        SubItems.Add(Clients[I].ClientPath);
      end;
    ClientsListView.Items[SelectedClientIndex].Selected := True;
    AutomaticRadioBtn.Enabled := AnyClientInstalled;
    MapiRadioBtn.Enabled := SimpleMapiInstalled;
    DirectRadioBtn.Enabled := ClientCount > 0;
  end;
  ClientsListView.Items.EndUpdate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BuildClientList;
  UpdateClientName;
end;

procedure TMainForm.ClientsListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    JvMail1.SimpleMAPI.SelectedClientIndex := Item.Index;
    UpdateClientName;
  end;
end;

procedure TMainForm.UpdateClientName;
begin
  ClientLabel.Caption := JvMail1.SimpleMAPI.CurrentClientName;
end;

procedure TMainForm.AutomaticRadioBtnClick(Sender: TObject);
begin
  with JvMail1.SimpleMAPI do
  begin
    if AutomaticRadioBtn.Checked then ClientConnectKind := ctAutomatic;
    if MapiRadioBtn.Checked then ClientConnectKind := ctMapi;
    if DirectRadioBtn.Checked then ClientConnectKind := ctDirect;
  end;
  UpdateClientName;
end;

procedure TMainForm.ClientsListViewCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if not Boolean(Item.Data) then
    Sender.Canvas.Font.Color := clInactiveCaption;
end;

procedure TMainForm.SendBtnClick(Sender: TObject);
begin
  JvMail1.Clear;
  JvMail1.Recipient.AddRecip(ToEdit.Text);
  if CcEdit.Text <> '' then JvMail1.CarbonCopy.AddRecip(CcEdit.Text);
  JvMail1.Subject := SubjectEdit.Text;
  JvMail1.Body.Text := BodyEdit.Text;
  JvMail1.Attachment.Assign(AttachmentMemo.Lines);
  JvMail1.SendMail;
end;

procedure TMainForm.AttachBtnClick(Sender: TObject);
begin
  JvOpenDialog1.FileName := '';
  if JvOpenDialog1.Execute then
    AttachmentMemo.Lines.AddStrings(JvOpenDialog1.Files);
end;

end.
