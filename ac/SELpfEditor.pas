unit SELpfEditor;

interface
uses
  DesignIntf, DesignEditors,
  SELowPassFilter, SELpfEditDlg, Controls, SysUtils;

type
  TSELpfEditor =class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): String; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;
procedure Register;

implementation

// �������������� �������� ����������
procedure Register;
begin
  RegisterComponentEditor(TLowPassFilter, TSELpfEditor);
end;

function TSELpfEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TSELpfEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit LowPassFilter';
    else
      Result := 'Undefined Menu';
  end;
end;

//
procedure TSELpfEditor.ExecuteVerb(Index: Integer);
var
  i:Integer;
  strTemp: string;
  Dialog: TSELpfEditDlg;

begin
  case Index of
  0:
    begin
      Dialog := TSELpfEditDlg.Create(nil);
      Dialog.Caption := Component.Owner.Name + '.' + Component.Name +' - ' + Dialog.Caption;
     // ����� ������
      if (Component as TLowPassFilter).Mode = mdNoneFiltering then
        Dialog.NoneFiltering.Checked := true
      else if (Component as TLowPassFilter).Mode = mdLowPassFilter then
             Dialog.LowPassFiltering.Checked := true
           else
             Dialog.SubstractNoise.Checked := true;
     // ������ �������
      Dialog.BandWidth.Text :=FloatToStr( (Component as TLowPassFilter).BandWidth);
     // ������� ���������� �� �������
      for i := 1 to 10 do
      begin
        Dialog.FrequencyResolution.Items[i - 1] := IntToStr(i);
        if i = (Component as TLowPassFilter).FrequencyResolution then
          Dialog.FrequencyResolution.ItemIndex := i - 1;
      end;
     // ������� ���������� ��������
      Dialog.CheckOvershoot.Checked := (Component as TLowPassFilter).OverShoot;
     // ������� ���������� �������� � ������� ��������� ����
      for i := 0 to 2 do
      begin
        case i of
          0: strTemp := 'Small';
          1: strTemp := 'Medium';
          2: strTemp := 'Large';
        end;
        Dialog.SuppressionDegree.Items[i] := strTemp;
        Dialog.SubstractionNoiseDegree.Items[i] := strTemp;
        if Ord((Component as TLowPassFilter).SuppressionDegree) = i then
          Dialog.SuppressionDegree.ItemIndex := i;
        if Ord((Component as TLowPassFilter).SubstractionNoiseDegree) = i then
          Dialog.SubstractionNoiseDegree.ItemIndex := i;
      end;

     // ���������� ������
      if Dialog.ShowModal = mrOK then
      begin
        // ������
        (Component as TLowPassFilter).BandWidth := StrToFloat(Dialog.BandWidth.Text);
        // ������� ���������� ��������
        case  Dialog.SuppressionDegree.ItemIndex of
          0: (Component as TLowPassFilter).SuppressionDegree := edSmall;
          1: (Component as TLowPassFilter).SuppressionDegree := edMedium;
          2: (Component as TLowPassFilter).SuppressionDegree := edLarge;
        end;
        // ����������
        (Component as TLowPassFilter).FrequencyResolution := Dialog.FrequencyResolution.ItemIndex + 1;
        // ������� ���������� ��������
        (Component as TLowPassFilter).Overshoot := Dialog.CheckOvershoot.Checked;
        // ������� ��������� ����
        case Dialog.SubstractionNoiseDegree.ItemIndex of
          0: (Component as TLowPassFilter).SubstractionNoiseDegree := edSmall;
          1: (Component as TLowPassFilter).SubstractionNoiseDegree := edMedium;
          2: (Component as TLowPassFilter).SubstractionNoiseDegree := edLarge;
        end;
        // ����� ������ �������
        if Dialog.NoneFiltering.Checked then
          (Component as TLowPassFilter).Mode := mdNoneFiltering
        else if Dialog.LowPassFiltering.Checked then
               (Component as TLowPassFilter).Mode := mdLowPassFilter
             else
               (Component as TLowPassFilter).Mode := mdSubtractionNoise;

        Designer.Modified;
      end;
      Dialog.Free;

    end;
  end;
end;

end.
