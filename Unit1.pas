unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, Vcl.StdCtrls,
  VCLTee.Series, VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs,
  VCLTee.Chart,Math, Vcl.ComCtrls;

type
  myArray = array [-100000..100000] of extended;
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Chart1: TChart;
    GroupBox1: TGroupBox;
    Series1: TLineSeries;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Chart2: TChart;
    ListBox1: TListBox;
    Edit3: TEdit;
    Series2: TLineSeries;
    Series3: TLineSeries;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Chart3: TChart;
    Button4: TButton;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Chart4: TChart;
    Edit4: TEdit;
    Label4: TLabel;
    Series7: TLineSeries;
    Series8: TBarSeries;
    Chart5: TChart;
    Label5: TLabel;
    Button5: TButton;
    Label6: TLabel;
    Label7: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Chart6: TChart;
    Series9: TBarSeries;
    Series10: TAreaSeries;
    Series11: TAreaSeries;
    Series12: TAreaSeries;
    Series13: TAreaSeries;
    Button6: TButton;
    Chart7: TChart;
    Series14: TPointSeries;
    Label8: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  jmldata, jmlr, fs :integer;
  hr :extended;
  sinyalecg, lpf, hpf, deriv, square, fw, bw, mav  :myArray;
  spki, npki, th, thresh, puncak, bpm1, bpm2, bpm3, bpm, time :myArray;
  dft_re, dft_im, hasildft :myArray;

implementation

{$R *.dfm}
procedure TForm1.Button2Click(Sender: TObject);
begin
  Series1.Clear; Series2.Clear; Series3.Clear;
  Series4.Clear; Series5.Clear; Series6.Clear;
  Series7.Clear; Series8.Clear; Series9.Clear;
  Series10.Clear; Series11.Clear; Series12.Clear;
  Series13.Clear; Series14.Clear;
  Edit1.Clear; Edit2.Clear; Edit3.Clear;
  Edit4.Clear; Edit5.Clear; Edit6.Clear;
  Edit7.Clear;
  Listbox1.Clear;
  button2.Enabled := false;
  button3.Enabled := false;
  button4.Enabled := false;
  button5.Enabled := false;
  button6.Enabled := false;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  del1, del2, val :string;
  ambildata :Tstringlist;
  fileecg :textfile;
  i :integer;
  t :extended;
begin
  ambildata := TstringList.Create;
  i := 0;

  if OpenDialog1.Execute then
    assignfile(fileecg,OpenDialog1.FileName);

  reset(fileecg);
  readln(fileecg,del1);
  ambildata.Delimiter:='(';
  readln(fileecg,del2);
  ambildata.DelimitedText := del2;
  t := strtofloat (ambildata[1]);
  while not EOF (fileecg) do
  begin
    readln(fileecg,val);
    sinyalecg[i]:= strtofloat(val);
    inc(i);
  end;
  closefile(fileecg);
  jmldata := i;
  fs := round(1/t);
  Edit1.Text := inttostr(jmldata);
  Edit2.Text := inttostr(fs);

  for i := 0 to jmldata-1 do
  begin
    Series1.AddY(sinyalecg[i]);
  end;
  button3.Enabled := true;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i,j,k :integer;
  max,maxn,rr :extended;
begin
  for i := 0 to jmldata-1 do
  begin
     lpf[i] := (2*lpf[i-1]) - lpf[i-2]   + sinyalecg[i]    - 2*sinyalecg[i-6] +  sinyalecg[i-12];
  end;

  for i := 0 to jmldata-1 do
  begin
    hpf[i]:=    hpf[i-1] - (lpf[i]/32) + lpf[i-16] - lpf[i-17]  + (lpf[i-32]/32);
    Series2.AddY(hpf[i]);
  end;

  for i := 0 to jmldata-1 do
  begin
    deriv[i] := (2*hpf[i] + hpf[i-1] - hpf[i-3] - 2*hpf[i-4])/8;
    Series3.AddY(deriv[i]);
  end;

  for i := 0 to jmldata-1 do
  begin
    square[i]:= sqr(deriv[i]);
    Series4.AddY(square[i]);
  end;

  for i := 0 to jmldata-1 do
  begin
    for j := 0 to 31 do
    begin
      fw[i]:= fw[i] + square[i-j];
    end;
    fw[i] := fw[i]/32;
  end;

  for i := 0 to jmldata-1 do
  begin
    for j := 0 to 31 do
    begin
      bw[i] := bw[i] + fw[i+j];
    end;
    bw[i] := bw[i]/32;
    Series5.AddY(bw[i]);
  end;

  max := bw[0];
  for i:= 0 to jmldata-1 do
  begin
    if bw[i]>= max then
    begin
      max:= bw[i];
    end;
  end;

  maxn:=0.4;
  for i := 0 to jmldata-1 do begin
    spki[i]:= 0.98*spki[i-1] + (1 - 0.98)*max;
    npki[i]:= 0.98*npki[i-1] + (1 - 0.98)*maxn;
    th[i]  := npki[i] + 0.4*(spki[i] - npki[i]);
    if bw[i]< th[i] then
      th[i]:=0
    else
      th[i]:=1;
    Series6.AddXY(i,th[i]);
  end;

  k:= 1;
  for i:=0 to jmldata-1 do
  begin
    if (th[i]=0) and (th[i+1]=1) then
    begin
      bpm1[k]:= i+1;
      time[k] := i;
      for j:=i+1 to jmldata-1 do
      begin
        if (th[j]=0) and (th[j+1]=1) then
        begin
          bpm2[k]:=j;
          inc(k);
          break;
        end;
      end;
    end;
  end;

  jmlr:= k;
  rr :=0;
  for i:=1 to jmlr-1 do
  begin
    bpm3[i]:=((bpm2[i]-bpm1[i])/fs);
    bpm3[i]:= roundto(bpm3[i],-3);
    rr := rr + bpm3[i];

    bpm[i]:= 60/((bpm2[i]-bpm1[i])/fs);
    bpm[i]:= roundto(bpm[i],-3);
    listbox1.Items.Add('RR['+inttostr(i)+']='+floattostr(bpm[i]));
    Series3.AddXY(i,bpm[i]);
    hr:= hr + bpm[i];
  end;
  rr := rr/(jmlr-1);
  hr := hr/(jmlr-1);
  hr := roundto(hr,-3);
  Edit3.Text:=floattostr(rr*1000);
  button2.Enabled := true;
  button4.Enabled := true;
  button5.Enabled := true;
  button6.Enabled := true;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i, j, k: integer;
  temp, rmssd :extended;
begin
  temp := 0;
  for i := 1 to jmlr-1 do
  begin
    Series7.AddY(bpm[i]);
    temp := temp + sqr(bpm3[i+3] - bpm3[i]);
  end;
  rmssd := sqrt(temp/(jmlr-1))*1000;
  Edit4.Text := floattostr(rmssd);

  for i := 1 to jmlr-1 do
  begin
    k := 1;
    for j := 1 to jmlr do
    begin
      if bpm3[i] = bpm3[j] then
        inc(k);
    end;
    Series8.AddXY(bpm3[i],k);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i,j :integer;
  x, y, lf, hf, lfhf_ratio :extended;
begin
  for i:= 1 to jmlr do begin
    dft_re[i]:= 0;
    dft_im[i]:= 0;
    for j:= 1 to jmlr do begin
      dft_re[i] := dft_re[i] + bpm3[j]*cos(2*pi*j*i/jmlr);
      dft_im[i] := dft_im[i] - bpm3[j]*sin(2*pi*j*i/jmlr);;
    end;
    hasildft[i]:= sqrt(sqr(dft_re[i])+sqr(dft_im[i]))/jmlr;
  end;

  for i := 0 to round(fs/2) do
  begin
    Series9.AddXY(i,hasildft[i]);
  end;

  //Ultra Low Frequency
  for i:= Round(0.0001*fs) to Round(0.003*fs) do begin
    series10.AddXY(i/fs,hasildft[i]);
  end;

  //Very Low Frequency
  for i:= Round(0.003*fs) to Round(0.04*fs) do begin
    series11.AddXY(i/fs,hasildft[i]);
  end;

  //Low Frequency
  x := 0;
  y := 0;
  for i:= Round(0.04*fs) to Round(0.15*fs) do begin
    series12.AddXY(i/fs,hasildft[i]);
    x := x + i*hasildft[i];
    y := y + hasildft[i]; //menjumlah semua spektrum HRV
  end;
  lf := x/y;

  //High Frequency
  x := 0;
  y := 0;
  for i:= Round(0.15*fs) to Round(0.4*fs) do begin
    series13.AddXY(i/fs,hasildft[i]);
    x := x + i*hasildft[i];
    y := y + hasildft[i]; //menjumlah semua spektrum HRV
  end;
  hf := x/y;
  lfhf_ratio := lf/hf;

  Edit5.Text := floattostr(roundto(lf,-3));
  Edit6.Text := floattostr(roundto(hf,-3));
  Edit7.Text := floattostr(roundto(lfhf_ratio,-3));
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to jmlr do
  begin
    Series14.AddXY(bpm3[i],bpm3[i+1]);
  end;
end;

end.
