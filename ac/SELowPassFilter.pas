unit SELowPassFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math;

const
 // ��� ��
  TwoPi: Double = 2 * Pi;
type
  TMode = (mdNoneFiltering, mdLowPassFilter, mdSubtractionNoise);
type
  TEnumDegree = (edSmall, edMedium, edLarge);
  TDigits = array of Double;
  TInteger = array of integer;
  TNotifyEventStep = procedure (Sender: TObject; Percent: double) of object;
  TLowPassFilter = class(TComponent)
  private
   // ����� ������ �������
    FMode: TMode;
   // ����� ������� �������
    FSampleCount: Integer;
   // ���������� ������������ ������������
    FSpectrumCount: Integer;
   // ���������� ��������� �����������
    FHistogramCount: Integer;
   // ���������� �������� ��������
    FHostHarmonicCount: Integer;
   // ������ �������
    FBandWidth: double;
   // ������� ���������� ��������
    FOvershoot: boolean;
   // ������� ���������� � ��������� �������
    FFrequencyResolution: Integer;
   // ������� ���������� ��������
    FSuppressionDegree: TEnumDegree;
   // ������� ��������� �����
    FSubstractionNoiseDegree: TEnumDegree;
   // ������� - ������ ���������
    FBeforeExecute: TNotifyEvent;
   // ������� - ��������� ���������
    FAfterExecute: TNotifyEvent;
   // ������� - ���������� �������� ���������
    FOnDeleteOvershoot: TNotifyEvent;
   // ������� - ��������� 5% ���������
    FOnStepExecute: TNotifyEventStep;
   // ���� - ���������� ���������� ���������
    FBreakExecute: boolean;
   // ����� ������������ ������������ ��� ���������� ������������
    SumSpectrum: Double;
   // ����� ��������� ������������ ������������ ��� ���������� ������������
    SquareSumSpectrum: Double;
   // ������� ������� ������������
    dblThreshold: double;
   // ���������� � ������� ���� �������� 2, ����� �������� ����� ������������ ������������
    NExp: Integer;
   // ������� ��� �������� ������� ������, �������� ������, �������� � ��������� ��������
    SQRe, SQIm, SpRe,SpIm,SpMod: TDigits;
    SQReO, SQImO, SpReO,SpImO,SpModO: TDigits;
   // ������ �������� ��������������� �� �������� ������������ ������������
    intIndex: TInteger;
   // �����������
    intHistogram: TInteger;
   // ������ �������� ��������
    dblHostHarmonic: TDigits;
   // ��������� ��������� �������� "������ �������"
    procedure SetBandWidth(Value: double);
   // ��������� ��������� �������� "������� ����������  �� �������"
    procedure SetFrequencyResolution(Value: integer);
   // ������� ���������������� �������� "������� ������� ������"
    function GetInputDataItem(Index: Integer) : double;
   // ������� ���������������� �������� "������� �������� ������"
    function GetOutputDataItem(Index: Integer) : double;
   // ������� ���������������� �������� "������� �������� �������"
    function GetInputSpectrumItem(Index: Integer) : double;
   // ������� ���������������� �������� "������� ��������� �������"
    function GetOutputSpectrumItem(Index: Integer) : double;
   // ������� ���������������� �������� "������� �����������"
    function GetHistogramItem(Index: Integer) : integer;
   // ������� ���������������� �������� "������� ������� �������� ��������"
    function GetHostHarmonicItem(Index: Integer): double;
   // ������� ��������� ����� ������������ ������������, ��������������� ������ �������
    function BandNumber: integer;
   // ������� ��������� ���������� ������������ ������������
    function CalcSpectrumCount: Integer;
   // ��������� �������� �������� �� ������� ������������������
    procedure DeleteOverchoos;
   // ������ ������� �������������� �����
    procedure BPF;
   // �������� ������� �������������� �����
    procedure BackBPF;
   // �������������� �������� ������� � ��������
    procedure LPFiltr;
   // ��������� ���������� ������� ��� ������� (���������� �� ��������)
    procedure BuildIndex(dblArray: TDigits; intIndex: TInteger; SizeArray: Integer; SendEvent: Boolean);
   // ������� ��������� ����� ������ ������������ ������������
    function CalcThreshold(dblArray: TDigits; intIndex: TInteger) : double;
   //  ��������� ������ �������� ��������
    procedure BuildHostHarmonicList;
   // ��������� ������ ��������� �� �� ������
    function CalcPeriodHarmonic(NumberHarmonic: Integer): double;
  public
    { Public declarations }
   // �����������
    constructor Create(AOwner: TComponent); override;
   // ����������
    destructor Destroy; override;
   // ����� - �������� ������, ���������� � �������
    procedure ClearArray;
   // ����� - �������� ������� ������� ������
    procedure AddInputDataItem(Value: double);
   // ����� - ���������� ���������
    procedure Execute;
   // ����� - �������� ���������
    procedure BreakExecute;
   // ��������������� �������� "������� ������� ������"
    property InputDataItem[index: Integer]: double read GetInputDataItem;
   // ��������������� �������� "������� �������� ������"
    property OutputDataItem[index: Integer]: double read GetOutputDataItem;
   // ��������������� �������� "������� �������� �������"
    property InputSpectrumItem[index: Integer]: double read GetInputSpectrumItem;
   // ��������������� �������� "������� ��������� �������"
    property OutputSpectrumItem[index: Integer]: double read GetOutputSpectrumItem;
    // ��������������� �������� "������� �����������"
    property HistogramItem[index: Integer]: Integer read GetHistogramItem;
    // �������� ���������
    property HostHarmonicItem[index: Integer]: double read GetHostHarmonicItem;
  published
    { Published declarations }
   // �������� "����� ������"
    property Mode: TMode read FMode write FMode;
   // �������� "���������� �������� ��������"
    property HostHarmonicCount: Integer read FHostHarmonicCount;
   // �������� "������ �������"
    property BandWidth: double read FBandWidth write SetBandWidth;
   // �������� " ������� ���������� �� �������"
    property FrequencyResolution: Integer read FFrequencyResolution write SetfrequencyResolution;
   // �������� "������� ���������� ��������"
    property SuppressionDegree: TEnumDegree read FSuppressionDegree write FSuppressionDegree;
   // �������� "������� ��������� �����"
    property SubstractionNoiseDegree: TEnumDegree read FSubstractionNoiseDegree write FSubstractionNoiseDegree;
   // �������� "�������� �������"
    property Overshoot: boolean read FOvershoot write FOvershoot;
   // �������� "����� ������� �������"
    property SampleCount: integer read FSampleCount;
   // �������� "���������� ������������ ������������"
    property SpectrumCount: integer read FSpectrumCount;
   // �������� "���������� ����� � �����������"
    property HistogramCount: integer read FHistogramCount;
   // �������� "������ ���������"
    property BeforeExecute: TNotifyEvent read FBeforeExecute write FBeforeExecute;
   // �������� "��������� ���������"
    property AfterExecute: TNotifyEvent read FAfterExecute write FAfterExecute;
   // �������� "���������� �������� ���������"
    property OnDeleteOvershoot: TNotifyEvent read FOnDeleteOvershoot write FOnDeleteOvershoot;
   // �������� "��������� ��������� 5% ���������"
    property OnStepExecute: TNotifyEventStep read FOnStepExecute write FOnStepExecute;
  end;


implementation

// �����������
constructor TLowPassFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMode := mdSubtractionNoise;
  FOvershoot := true;
  FFrequencyResolution := 2;
  FBandWidth := 0.1;
  FSuppressionDegree := edMedium;
  FSubstractionNoiseDegree := edMedium;
end;
// ����������
destructor TLowPassFilter.Destroy;
begin
  SQRe := nil;
  inherited Destroy;
end;
// ����� - �������� ��� ������ �������
procedure TLowPassFilter.ClearArray;
begin
   SQRe := nil;
   SQIm := nil;
   SpRe := nil;
   SpIm := nil;
   SpMod := nil;
   SQReO := nil;
   SQImO := nil;
   SpReO := nil;
   SpImO := nil;
   SpModO := nil;
   FSampleCount := 0;
   FSpectrumCount :=0;
end;

/////////////////////////////////////////////
// ����� - �������� ������� ������� ������ //
/////////////////////////////////////////////
procedure TLowPassFilter.AddInputDataItem(Value: double);
begin
 FSampleCount := FSampleCount + 1;
 SetLength(SQRe, FSampleCount);
 SQRe[FSampleCount - 1] := Value;
end;

///////////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� �������� ������ //
///////////////////////////////////////////////////////////////////
function TLowPassFilter.GetOutputDataItem(Index: integer): double;
begin
 if (Index < FSampleCount) and (Index >= 0) then
   Result := SQReO[Index]
 else
   Result := 0;
end;

//////////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� ������� ������ //
//////////////////////////////////////////////////////////////////
function TLowPassFilter.GetInputDataItem(Index: integer): double;
begin
 if (Index < FSampleCount) and (Index >=0) then
   Result := SQRe[Index]
 else
   Result := 0;
end;

////////////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� �������� ������� //
////////////////////////////////////////////////////////////////////
function TLowPassFilter.GetInputSpectrumItem(Index: integer): double;
begin
  if (Index < FSpectrumCount) and (Index>=0) then
    Result := SpMod[Index]
  else
    Result := 0;
end;

/////////////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� ��������� ������� //
/////////////////////////////////////////////////////////////////////
function TLowPassFilter.GetOutputSpectrumItem(Index: Integer): double;
begin
  if (Index < FSpectrumCount) and (Index>=0) then
    Result := SpModO[Index]
  else
    Result := 0;
end;

///////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� ����������� //
///////////////////////////////////////////////////////////////
function TLowPassFilter.GetHistogramItem(Index: Integer): Integer;
begin
  if (Index < FHistogramCount) and (Index >= 0) then
    Result := intHistogram[Index]
  else
    Result := 0;
end;

///////////////////////////////////////////////////////////////
// ��������������� �������� - ���������� ������� ����������� //
///////////////////////////////////////////////////////////////
function TLowPassFilter.GetHostHarmonicItem(Index: Integer): double;
begin
  if (Index < FHostHarmonicCount) and (Index >=0) then
    Result := dblHostHarmonic[Index]
  else
    Result:= 0;
end;

//////////////////////////////////
// ����� - ��������� ���������  //
//////////////////////////////////
procedure TLowPassFilter.Execute;
var
  i: Integer;
  dblSteadyComponent: double;
begin
  FBreakExecute := false;
  if Assigned(FBeforeExecute) then
    FBeforeExecute(Self);
  FSpectrumCount := CalcSpectrumCount;
  if FSampleCount > 0 then
  begin
    // ������ ���������� �������
    if Overshoot then
      DeleteOverchoos;
    // ������ ���������� ������������
    dblSteadyComponent := 0;
    for i := 0 to FSampleCount - 1 do
      dblSteadyComponent := dblSteadyComponent + SQRe[i];
    dblSteadyComponent := dblSteadyComponent / FSampleCount;
    for i := 0 to FSampleCount -1 do
      SQRe[i] := SQRe[i] - dblSteadyComponent;

    // ������ �������������� �����
    if not FBreakExecute  then BPF;
    // �������������� �������
    if not FBreakExecute then LPFiltr;
    // ��������� ������ �������� ��������
    if not FBreakExecute then  BuildHostHarmonicList;
    // �������� �������������� �����
    if not FBreakExecute then BackBPF;
    // ������������ ���������� ������������
    for i := 0 to FSampleCount -1 do
    begin
        SQReO[i] := SQReO[i] + dblSteadyComponent;
        SQRe[i] := SQRe[i] + dblSteadyComponent;
    end;
  end;
  if Assigned(FAfterExecute) then
    FAfterExecute(Self);
end;

//////////////////////////////////
// ����� - �������� ���������  //
//////////////////////////////////
procedure TLowPassFilter.BreakExecute;
begin
  FBreakExecute := true;
end;

//////////////////////////////////////////////////////
// �������� - ���������� ������ ����������� (0 - 1) //
//////////////////////////////////////////////////////
procedure TLowPassFilter.SetBandWidth(Value: double);
begin
  if Value > 1 then
    FBandWidth := 1
  else
    if Value < 0 then
      FBandWidth := 0
    else
      FBandWidth := Value;
end;

//////////////////////////////////////////////////////////
// �������� - ���������� ������� ���������� �� �������. //
//////////////////////////////////////////////////////////
procedure TLowPassFilter.SetFrequencyResolution(Value: integer);
begin
  if (Value >= 1) and (Value <=10) then
    FFrequencyResolution := Value;
end;

////////////////////////////////////////////////////////////////////////////////
// �� �������� ������ ���������� ������������ ����� ������������ ������������ //
////////////////////////////////////////////////////////////////////////////////
function TLowPassFilter.BandNumber:Integer;
begin
  BandNumber := Round(FSpectrumCount / 2 * BandWidth);
end;

/////////////////////////////////
// ��������� ��������� ������� //
/////////////////////////////////
procedure TLowPassFilter.LPFiltr;
var
  n, i: integer;
begin
  // ��������� ������ �� �������� ��� ������������ �������� �������
  intIndex := nil;
  SetLength(intIndex,FSpectrumCount);
  BuildIndex(SpMod, intIndex, FSpectrumCount, true);
  if  FBreakExecute then exit;
  // ����� ������� ������ ������
  if (Mode = mdLowPassFilter) or (Mode = mdNoneFiltering) then
  begin
    if Mode = mdLowPassFilter then
      n := BandNumber()
    else n := FSpectrumCount div 2;
    SpReO[0] := SpRe[0];
    SpImO[0] := SpIm[0];
    SpModO[0] := SpMod[0];
    for i := 1 to FSpectrumCount div 2 do
      if i > n then
      begin
        SpReO[i] := 0;
        SpImO[i] := 0;
        SpModO[i] := 0;
        SpReO[FSpectrumCount - i] := 0;
        SpImO[FSpectrumCount - i] := 0;
        SpModO[FSpectrumCount - i] := 0;
      end
      else
      begin
        SpReO[i] := SpRe[i];
        SpImO[i] := SpIm[i];
        SpModO[i] := SpMod[i];
        SpReO[FSpectrumCount - i] := SpRe[FSpectrumCount - i];
        SpImO[FSpectrumCount - i] := SpIm[FSpectrumCount-i];
        SpModO[FSpectrumCount-i] := SpMod[FSpectrumCount-i];
      end;
  end
  // ����� ��������� ����
  else if Mode = mdSubtractionNoise then
       begin
         dblThreshold := CalcThreshold(SpMod, intIndex);
         // �������� ������������, ����������� �����
         for i := 0 to FSpectrumCount -1 do
           if SpMod[i] > dblThreshold then
             begin
               SpReO[i] := SpRe[i];
               SpImO[i] := SpIm[i];
               SpModO[i] := SpMod[i];
             end;
       end;
end;

////////////////////////////////////
// ���������� ���������� �������� //
////////////////////////////////////
procedure TLowPassFilter.DeleteOverchoos;
var
  i:Integer;
  xPred, xS, xD, xKrit:Double;
  xSupportArray: TDigits;
  xIndex: TInteger;
begin
  xSupportArray := nil;
  SetLength(xSupportArray, FSampleCount - 1);
  // ������������������� ������� �������
  for i := 0 to FSampleCount - 2 do
    xSupportArray[i] := abs(SQRe[i+1] - SQRe[i]);
  // ��������� ������ �� �������� ��� ���������
  xIndex := nil;
  SetLength(xIndex,FSampleCount - 1 );
  BuildIndex(xSupportArray, xIndex, FSampleCount - 1, false);
  // ������� ���������
  xS := xSupportArray[xIndex[FSampleCount div 2]];
  // ������ ���������� ��������� �� ������
  for i := 0 to FSampleCount - 2 do
    xSupportArray[i] := abs(xSupportArray[i] - xS);
  // ��������� ������ �� �������� ��� ����������
  BuildIndex(xSupportArray, xIndex, FSampleCount - 2, false);
  // ������� ���������� ���������
  xD := xSupportArray[xIndex[FSampleCount div 2]];
  // ������� ���������� ��������
  if FSuppressionDegree = edMedium then
    xKrit :=xS + xD * 3
  else if FSuppressionDegree = edLarge then
         xKrit :=xS + xD * 2
       else
         xKrit :=xS + xD * 4;
  xPred := SQRe[0];
  for i := 0 to FSampleCount - 1 do
  begin
    if abs(SQRe[i] - xPred) >= xKrit then
      if (SQRe[i] - xPred)>0 then
        SQRe[i] := xPred + xKrit
      else
        SQRe[i] := xPred - xKrit;
    xPred:=SQRe[i];
  end;
  if Assigned(FOnDeleteOvershoot) then
    FOnDeleteOvershoot(Self);
end;

///////////////////////////////////////////////
// ��������� ���������� ������������ ������� //
///////////////////////////////////////////////
function TLowPassFilter.CalcSpectrumCount: Integer;
var
  i, n :Integer;
begin
  n := 1;
  i := 0;
  while n < FSampleCount do
  begin
    n := n * 2;
    i := i + 1;
  end;
  Nexp := i + FFrequencyResolution - 1;
  for i := 1 to FFrequencyResolution - 1 do
    n := n * 2;

  FSpectrumCount := n;
  SetLength(SQRe,n);

  SQIm := nil;
  SQReO := nil;
  SQImO := nil;
  SpRe := nil;
  SpIm := nil;
  SpMod := nil;
  SpReO := nil;
  SpImO := nil;
  SpModO := nil;

  SetLength(SQIm,n);
  SetLength(SQReO,n);
  SetLength(SQImO,n);
  SetLength(SpRe,n);
  SetLength(SpIm,n);
  SetLength(SpMod,n);
  SetLength(SpReO,n);
  SetLength(SpImO,n);
  SetLength(SpModO,n);
  Result := n;
end;

//////////////////////////////////////////////////////////////
// ��������� �������� �������� ������� �������������� ����� //
//////////////////////////////////////////////////////////////
procedure TLowPassFilter.Bpf;
var
  xC1re,xC1im,xC2re,xC2im,xVre,xVim : double;
  i,j,k : integer;
  xMm,xLl,xJj,xKk,xNn,xNv2,xNm1: integer;
  xCounter, xNecessary: Integer;
begin
// copy
  for i := 0 to FSpectrumCount - 1 do
  begin
    SpIm[i] := 0;
    SpMod[i] := 0;
    if i < FSampleCount then
      SpRe[i]:=SQRe[i]
    else
      SpRe[i]:=0;
  end;

  //Begin
  xCounter := 0;
  xNecessary := Round(FSpectrumCount * log2(FSpectrumCount));
  xMm:=1;
  xLl:=FSpectrumCount;

  // ������� ���� ��� ����� Nexp
  for k := 1 to Nexp do
  begin
    xNn:=xLl div 2;
    xJj:=xMm+1;
   // ������������������ � ��������������� ����������
    i:=1;
    while i <= FSpectrumCount do
    begin
      xKk := i + xNn;
      xC1re := SpRe[i-1] + SpRe[xKk-1];
      xC1im := SpIm[i-1] + SpIm[xKk-1];
      SpRe[xKk-1] := SpRe[i-1] - SpRe[xKk-1];
      SpIm[xKk-1] := SpIm[i-1] - SpIm[xKk-1];
      SpRe[i-1] := xC1re;
      SpIm[i-1] := xC1im;
      i := i + xLl;
    end;

    if xNn <> 1 then
    begin
     // ������������ �������������� �����
      for j := 2 to xNn do
      begin
        xC2re := Cos(TwoPi * (xJj-1) / FSpectrumCount);
        xC2im := -Sin(TwoPi * (xJj-1)/ FSpectrumCount);
        xCounter := xCounter + 2;
        i := j;
        while i <= FSpectrumCount do
        begin
          xKk := i + xNn;
          xC1re := SpRe[i-1] + SpRe[xKk-1];
          xC1im := SpIm[i-1] + SpIm[xKk-1];
          xVre := (SpRe[i-1] - SpRe[xKk-1]) * xC2re - (SpIm[i-1] - SpIm[xKk-1]) * xC2im;
          xVim := (SpRe[i-1] - SpRe[xKk-1]) * xC2im + (SpIm[i-1] - SpIm[xKk-1]) * xC2re;
          SpRe[xKk-1] := xVre;
          SpIm[xKk-1] := xVim;
          SpRe[i-1] := xC1re;
          SpIm[i-1] := xC1im;
          i := i+xLl;

          xCounter := xCounter + 2;
          if (xCounter mod (xNecessary div 20) = 0) then
            begin
              Application.ProcessMessages;
              if FBreakExecute then exit;
              if Assigned(FOnStepExecute) then
                FOnStepExecute(Self, xCounter / xNecessary * 33);
            end;
        end;

        xJj := xJj + xMm;
      end;

      xLl := xNn;
      xMm := xMm * 2;
    end;

  end;

  // �������������� ������ ������������������
  xNv2 := FSpectrumCount div 2;
  xNm1 := FSpectrumCount - 1;
  j := 1;

  for i := 1 to xNm1 do
  begin
    if i < j then
    begin
      xC1re := SpRe[j-1];
      xC1im := SpIm[j-1];
      SpRe[j-1] := SpRe[i-1];
      SpIm[j-1] := SpIm[i-1];
      SpRe[i-1] := xC1re;
      SpIm[i-1] := xC1im;
    end;
    k := xNv2;
    while k < j do
    begin
      j := j - k;
      k := k div 2;
    end;
    j := j + k;

  end;

  // ���������� ������
  SumSpectrum := 0;
  SquareSumSpectrum :=0;
  for i := 0 to FSpectrumCount - 1 do
  begin
    SpMod[i] := Sqrt(SpRe[i] * SpRe[i] + SpIm[i] * SpIm[i]);
    if i<>0 then
    begin
      SumSpectrum := SumSpectrum + SpMod[i];
      SquareSumSpectrum := SquareSumSpectrum + SpMod[i] * SpMod[i];
    end;
  end;
end;

////////////////////////////////////////////////////////////////
// ��������� �������� �������� ��������� �������������� ����� //
////////////////////////////////////////////////////////////////
procedure TLowPassFilter.BackBpf;
var
  xC1re,xC1im,xC2re,xC2im,xVre,xVim : double;
  i,j,k : integer;
  xMm,xLl,xJj,xKk,xNn,xNv2,xNm1: integer;
  xCounter, xNecessary: Integer;
begin
// ���������� �������� ������ � �������� �����
  for i:=0 to FSpectrumCount-1 do
  begin
    SQReO[i] := SpReO[i];
    SQImO[i] := SpImO[i];
  end ;

  //Begin
  xCounter := 0;
  xNecessary := Round(FSpectrumCount * log2(FSpectrumCount));
  xMm := 1;
  xLl := FSpectrumCount;

  // ������� ���� ��� ����� Nexp
  for k := 1 to Nexp do
  begin
    xNn := xLl div 2;
    xJj := xMm + 1;
    // ������������������ � ��������������� ����������
    i := 1;
    while i <= FSpectrumCount do
    begin
      xKk := i + xNn;
      xC1re := SQReO[i-1] + SQReO[xKk-1];
      xC1im := SQImO[i-1] + SQImO[xKk-1];
      SQReO[xKk-1] := SQReO[i-1] - SQReO[xKk-1];
      SQImO[xKk-1] := SQImO[i-1] - SQImO[xKk-1];
      SQReO[i-1] := xC1re;
      SQImO[i-1] := xC1im;
      i := i + xLl;
    end;

    if xNn <> 1 then
    begin
     // ������������ �������������� �����
      for j := 2 to xNn do
      begin
        xC2re := Cos(TwoPi * (xJj - 1) / FSpectrumCount);
        xC2im := Sin(TwoPi * (xJj - 1) / FSpectrumCount);
        xCounter := xCounter + 2;
        i := j;
        while i <= FSpectrumCount do
        begin
          xKk := i + xNn;
          xC1re := SQReO[i - 1] + SQReO[xKk - 1];
          xC1im := SQImO[i - 1] + SQImO[xKk - 1];
          xVre := (SQReO[i - 1] - SQReO[xKk - 1]) * xC2re - (SQImO[i - 1] - SQImO[xKk - 1]) * xC2im;
          xVim := (SQReO[i - 1] - SQReO[xKk - 1]) * xC2im + (SQImO[i - 1] - SQImO[xKk - 1]) * xC2re;
          SQReO[xKk - 1] := xVre;
          SQImO[xKk - 1] := xVim;
          SQReO[i - 1] := xC1re;
          SQImO[i - 1] := xC1im;
          i := i + xLl;

          xCounter := xCounter + 2;
          if (xCounter mod (xNecessary div 20) = 0) then
            Begin
              Application.ProcessMessages;
              if FBreakExecute then exit;
              if Assigned(FOnStepExecute) then
                FOnStepExecute(Self,66 + xCounter / xNecessary * 33);
            end;
        end;

        xJj := xJj + xMm;
      end;

      xLl := xNn;
      xMm := xMm * 2;
    end;
  end;

  // �������������� ������ ������������������
  xNv2 := FSpectrumCount div 2;
  xNm1 := FSpectrumCount - 1;
  j := 1;

  for i := 1 to xNm1  do
  begin
    if i < j then
    begin
      xC1re := SQReO[j - 1];
      xC1im := SQImO[j - 1];
      SQReO[j - 1] := SQReO[i - 1];
      SQImO[j - 1] := SQImO[i - 1];
      SQReO[i - 1] := xC1re;
      SQImO[i - 1] := xC1im;
    end;
    k := xNv2;
    while k < j do
    begin
     j := j - k;
     k := k div 2;
    end;
    j := j + k;
  end;
  
  // ����������� ��������� ���
  SumSpectrum := 0;
  for i := 0 to FSpectrumCount-1 do
  begin
    SQReO[i] := SQReO[i] / FSpectrumCount;
    SQImO[i] := SQImO[i] / FSpectrumCount;
  end;
end;

////////////////////////////////////////////////////////////////
// ���������� ������� ��� ������� (���������� �� ��������) //
////////////////////////////////////////////////////////////////
procedure TLowPassFilter.BuildIndex(dblArray: TDigits; intIndex: TInteger; SizeArray: Integer; SendEvent: Boolean);
var
  i, n: Integer;
  xTotalCount, xCurrentCount: Integer;
  xN1, xN2, xN1z, xN2z, xZ, xOrd: Integer; // ������� ������� � �� �������
  xTemporary: TInteger; // ������ ������� ��������
begin
  if SizeArray <=0 then exit;

//  xCurrentCount := 0;
  xTotalCount := 0;

  if SendEvent  then
  begin
    xCurrentCount :=0;
    xTotalCount := Round(SizeArray * log2(SizeArray));
  end;

  SetLength(xTemporary, SizeArray);
  for i := 0 to SizeArray - 1 do
    intIndex[i] := i;
  xZ := 1; // ��������� ������ ���� �������
  While (xZ < SizeArray) do
  begin
    xN1 := 0;
    While (xN1 < SizeArray) do
    begin
      xN1z :=xN1 + xZ;
      if xN1z > SizeArray then xN1z := SizeArray;
      xN2 := xN1z;
      xN2z := xN2 +xZ;
      if xN2z > SizeArray then xN2z := SizeArray;

      n := xN1;
      While ((xN1 < xN1z) or (xN2 < xN2z)) do  // ����� �� ���
      begin

        
        if SendEvent then
        begin
          Inc(xCurrentCount);
          if (xCurrentCount mod (xTotalCount div 20) = 0) then
            begin
              Application.ProcessMessages;
              if FBreakExecute then exit;
              if Assigned(FOnStepExecute) then
                FOnStepExecute(Self,33 + xCurrentCount / xTotalCount * 33);
            end;
        end;

        if xN2 >= xN2z then
          xOrd := 1
        else if xN1 >= xN1z then
               xOrd := 2
             else if dblArray[intIndex[xN1]] > dblArray[intIndex[xN2]] then
                    xOrd := 1
                  else
                    xOrd := 2;
        if xOrd = 1 then
        begin
          xTemporary[n] := intIndex[xN1];
          Inc(xN1);
        end
        else
        begin
          xTemporary[n] := intIndex[xN2];
          Inc(xN2);
        end;
        Inc(n);
      end;
      xN1 := xN2;
    end;
    for i := 0 to SizeArray - 1 do
      intIndex[i] := xTemporary[i];
    xZ := xZ * 2;
  end;
  xTemporary := nil;
end;

////////////////////////////////////////////
// ���������� ������ ������� ������������ //
////////////////////////////////////////////
function TLowPassFilter.CalcThreshold(dblArray: TDigits; intIndex: TInteger) : double;
var
  i, n, k : integer;
  xWeightingFactor: double;
  xHistogramInterval, xMaxValue, xMinValue : double;
begin
  // ���������� ����� ����� � ����������� �� ��������� �������
  n := Round(1 + 3.2 * log10(FSpectrumCount));
  if n < 20 then n := 20;
  FHistogramCount := n;
  // ���������� ������� �����������
  if FSubstractionNoiseDegree = edMedium then
    xWeightingFactor := 0.06
  else if FSubstractionNoiseDegree = edSmall then
         xWeightingFactor := 0.1
       else
         xWeightingFactor := 0.03;

  intHistogram := nil;
  SetLength(intHistogram, n);
  xMaxValue := dblArray[intIndex[0]];
  xMinValue := dblArray[intIndex[High(intIndex)]];
  xHistogramInterval := (xMaxValue - xMinValue) / n;
  // ��������� �����������
  for i := 0 to FSpectrumCount - 1 do
  begin
    k := Trunc((dblArray[i] -xMinValue) / xHistogramInterval);
    if k >=n then
      k := n-1;
    intHistogram[k] := intHistogram[k]+1 ;
  end;
  // ����� �������� �������������
  k := 0;
  for i := 1 to n - 1 do
    if intHistogram[i] > intHistogram[k] then k := i;
  // ����� �����
  i := k;
  repeat
    i := i + 1
  until (intHistogram[i] < xWeightingFactor * intHistogram[k]) or (i = n - 1);
  // ������� ���������
  if i < n - 1 then
    Result := xMinValue + xHistogramInterval * (i + 1)
  else
    Result := xMaxValue;
end;

////////////////////////////////////////
// ��������� ������ �������� �������� //
////////////////////////////////////////
procedure TLowPassFilter.BuildHostHarmonicList;
var
  i, n: integer;
  dblTempArray: TDigits;
  intTempNumberHarmonic: TInteger;
  intTempIndex: TInteger;
begin
  dblHostHarmonic := nil;
  dblTempArray := nil;
  intTempIndex := nil;
  intTempNumberHarmonic := nil;
  n := 0;
  // ��������� ������ ���������
  if (SpModO[1] > SpModO[2]) and (SpModO[1] >= SpModO[0]) and((SpModO[1] > dblThreshold) or (Mode = mdLowPassFilter)) then
  begin
    Inc(n);
    SetLength(dblTempArray, n);
    SetLength(intTempNumberHarmonic,n);
    dblTempArray[n - 1] := SpModO[1];
    intTempNumberHarmonic[n - 1] := 1;
  end;
 // ���������
  for i := 2 to FSpectrumCount div 2 do
    begin
      if (SpModO[i] > SpModO[i + 1]) and (SpModO[i] >= SpModO[i - 1]) and ((SpModO[i] > dblThreshold)  or (Mode = mdLowPassFilter) or (Mode =mdNoneFiltering)) then
      begin
        Inc(n);
        SetLength(dblTempArray, n );
        SetLength(intTempNumberHarmonic,n);
        dblTempArray[n - 1] := SpModO[i];
        intTempNumberHarmonic[n - 1] := i;
      end;
    end;
  // �����������
  intTempIndex := nil;
  SetLength(intTempIndex,n);
  BuildIndex(dblTempArray, intTempIndex, n, false);
  // ��������� ������ �������� ��������
  SetLength(dblHostHarmonic,n);
  for i := 0 to n - 1 do
    dblHostHarmonic[i] := CalcPeriodHarmonic(intTempNumberHarmonic[intTempIndex[i]]);
  FHostHarmonicCount := n;
end;

/////////////////////////////////////////////////////////////////////////////
// ��������� ������ ��������� � ���������� ��������� �������� �� �� ������ //
/////////////////////////////////////////////////////////////////////////////
function TLowPassFilter.CalcPeriodHarmonic(NumberHarmonic: Integer): double;
begin
  Result :=  (FSampleCount / NumberHarmonic) * (FSpectrumCount / FSampleCount);
end;
end.
