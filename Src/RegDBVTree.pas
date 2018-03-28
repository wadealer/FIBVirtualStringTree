{***************************************************************}
{  TDBVirtualStringTree - DB TreeView for Delphi 6,7            }
{                                                               }
{    TDBVirtualStringTree is a descendant of                    }
{    TVirtualStringTree component released September 30, 2000   }
{                                                               }
{    It requires VirtualTreeView: www.lischke-online.de         }
{                                                               }
{    Copyright (c) 10.2002 Serge Buzadzhy                       }
{    Contact: buzz@devrace.com                                  }
{                                                               }
{    Home page      : http://www.fibplus.net                    }
{                     http://www.devrace.com                    }
{                                                               }
{    You are allowed to used this component in any project      }
{    for free. You are NOT allowed to claim that you have       }
{    created this component or to copy its code into your own   }
{    component and claim that it was your idea.                 }
{                                                               }
{    It is also NOT allowed to remove or change the text of     }
{    this description!                                          }
{                                                               }
{***************************************************************}
unit RegDBVTree;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, VirtualTrees,DBVirtualStringTree,
  Graphics
  ;


procedure Register;

implementation

uses
   {$IFNDEF VER130}
     DesignEditors,DesignIntf, Variants,
     VCLEditors;
   {$ELSE}
     DsgnIntf ;
   {$ENDIF}


{$IFNDEF VER130}
type
  TDBTreeImageIndexEditor=class(TIntegerProperty,ICustomPropertyListDrawing)
    function GetAttributes : TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
   procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
     var AWidth: Integer);
  end;


{ TDBTreeImageIndexEditor }

function TDBTreeImageIndexEditor.GetAttributes: TPropertyAttributes;
begin
 Result:=[paValueList];
end;

procedure TDBTreeImageIndexEditor.GetValues(Proc: TGetStrProc);
var T : TVTImageIndexes;
    i : integer;
begin
   T:=GetComponent(0) as TVTImageIndexes;
   If Assigned(T) then
   begin
     If (Assigned(T.Owner.Images)) then
       for I:=0 to T.Owner.Images.Count-1 do Proc(IntToStr(i));
    end;
end;

procedure TDBTreeImageIndexEditor.ListDrawValue(const Value: string;
ACanvas: TCanvas;
   const ARect: TRect; ASelected: Boolean);
var T : TVTImageIndexes;
begin
   T:=GetComponent(0) as TVTImageIndexes;
   If Assigned(T) then
   begin
     If (Assigned(T.Owner.Images)) then
     begin
       ACanvas.TextRect(ARect, ARect.Left + 2+T.Owner.Images.Width, ARect.Top + 1,
Value);
       If Value<>'' then
        T.Owner.Images.Draw(ACanvas,ARect.Left+1,ARect.Top+1,StrToInt(Value));
     end;
   end;
end;

procedure TDBTreeImageIndexEditor.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
var T : TVTImageIndexes;
begin
   T:=GetComponent(0) as TVTImageIndexes;
   If Assigned(T) then
   begin
     If (Assigned(T.Owner.Images)) then AHeight:=T.Owner.Images.Height+2;
   end;
end;

procedure TDBTreeImageIndexEditor.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
begin
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents('Virtual Controls', [TDBVirtualStringTree]);
{$IFNDEF VER130}
  RegisterPropertyEditor(TypeInfo(integer),TVTImageIndexes,'ExpandedImage',
    TDBTreeImageIndexEditor);

  RegisterPropertyEditor(TypeInfo(integer),TVTImageIndexes,'CollapsedImage',
    TDBTreeImageIndexEditor);
  RegisterPropertyEditor(TypeInfo(integer),TVTImageIndexes,'ChildImage',
    TDBTreeImageIndexEditor);
{$ENDIF}
end;


end.
