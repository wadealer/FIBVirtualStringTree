{***************************************************************}
{                                                               }
{    TDBVirtualStringTree interfaces for Devrace FIBPlus        }
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

unit FIBVTreeCmps;

interface
uses Classes,SysUtils,pFIBQuery,DB,pFIBDataSet,RDIntfs;

type
     TVTFIBQuery =class(TpFIBQuery,IDBRetrieveData)
     private
      procedure ISetParamValue(const ParamName:string;Value:Variant);
      function  IGetParamValue(const ParamName:string;Value:Variant):Variant;
      procedure IOpen;
      procedure IClose;
      function  IGetFieldValue(const FieldName:string):Variant;
      function  IGetFieldCount:integer;
      function  IEof:Boolean;
      procedure INext;
      function  IFieldExist(const FieldName:string):boolean;
      function  IFieldWidth(const FieldName:string):integer;
      function  IParamExist(const ParamName:string):boolean;
      function  IDisplayFieldName(const FieldName:string):string;
      function  IGetInstance:TObject;
     public
     end;

     TVTFIBDataSet =class(TpFIBDataSet,IDBRetrieveData,IDBModifyData)
     private
      procedure ISetParamValue(const ParamName:string;Value:Variant);
      function  IGetParamValue(const ParamName:string;Value:Variant):Variant;
      procedure IOpen;
      procedure IClose;
      function  IGetFieldValue(const FieldName:string):Variant;
      function  IGetFieldCount:integer;
      function  IEof:Boolean;
      procedure INext;
      function  IFieldExist(const FieldName:string):boolean;
      function  IFieldWidth(const FieldName:string):integer;
      function  IParamExist(const ParamName:string):boolean;
      function  IDelete(const IDParamName:string;const Value:Variant):boolean;
      function  IUpdate(const FieldNames,Values:array of variant):boolean;
      function  IInsert(const FieldNames,Values:array of variant):boolean;
      function  IRefresh(const IDParamName:string;const Value:Variant;var Return:array of variant):boolean;
      function  IDisplayFieldName(const FieldName:string):string;
      function  IGetNewID:Integer;
      function  IGetInstance:TObject;
     public

     end;


procedure Register;

implementation


uses FIBQuery, FIBDataSet;

procedure Register;
begin
  RegisterComponents('Virtual Controls', [TVTFIBQuery,TVTFIBDataSet]);
end;

{ TVTFIBQuery }


procedure TVTFIBQuery.IClose;
begin
 Close
end;

function TVTFIBQuery.IDisplayFieldName(const FieldName: string): string;
begin
 Result:=FieldName
end;

function TVTFIBQuery.IEof: Boolean;
begin
 Result:=Eof
end;

function TVTFIBQuery.IFieldExist(const FieldName: string): boolean;
begin
  if not Prepared then Prepare ;
  Result:= FieldIndex[FieldName]>=0
end;

function TVTFIBQuery.IFieldWidth(const FieldName: string): integer;
var i:integer;
begin
 Result:=0;
 i:=FieldIndex[FieldName];
 if i>=0 then
 begin
  with Fields[i] do
   if IsNumericType(SQLType) or  IsDateTimeType(SQLType) then
    Result:=12
   else
    Result:=Size;    
 end;
end;

function TVTFIBQuery.IGetFieldCount: integer;
begin
 Result:=FieldCount
end;

function TVTFIBQuery.IGetFieldValue(const FieldName: string): Variant;
begin
 Result:=FieldByName(FieldName).Value;
end;

function TVTFIBQuery.IGetInstance: TObject;
begin
 Result:=Self
end;

function TVTFIBQuery.IGetParamValue(const ParamName: string;
  Value: Variant): Variant;
begin
 Result:=ParamByName(ParamName).Value;
end;

procedure TVTFIBQuery.INext;
begin
 Next
end;

procedure TVTFIBQuery.IOpen;
begin
 ExecQuery
end;

function TVTFIBQuery.IParamExist(const ParamName: string): boolean;
begin
 Result:=FindParam(ParamName)<>nil
end;

procedure TVTFIBQuery.ISetParamValue(const ParamName: string;
  Value: Variant);
begin
 ParamByName(ParamName).Value:=Value
end;

{ TVTFIBDataSet }


procedure TVTFIBDataSet.IClose;
begin
 Close
end;

function TVTFIBDataSet.IDelete(const IDParamName: string;
  const Value: Variant): boolean;
begin
 QDelete.ParamByName(IDParamName).Value:=Value;
 QDelete.ExecQuery;
 Result:=QDelete.RowsAffected>0;
 if Result then
    AutoCommitUpdateTransaction
end;

function TVTFIBDataSet.IDisplayFieldName(const FieldName: string): string;
begin
 Result:=FbN(FieldName).DisplayLabel
end;

function TVTFIBDataSet.IEof: Boolean;
begin
 Result:=Eof
end;

function TVTFIBDataSet.IFieldExist(const FieldName: string): boolean;
begin
 if FieldCount=0  then
 begin
  FieldDefs.Update;
  CreateFields;
 end;
 Result:=FN(FieldName)<>nil;
end;

function TVTFIBDataSet.IFieldWidth(const FieldName: string): integer;
begin
 with FbN(FieldName) do
 case DataType of
   ftString: Result:=Size;
 else
   Result:=10
 end;
end;

function TVTFIBDataSet.IGetFieldCount: integer;
begin
 Result:=FieldCount
end;

function TVTFIBDataSet.IGetFieldValue(const FieldName: string): Variant;
begin
 Result:=FbN(FieldName).Value;
end;

function TVTFIBDataSet.IGetInstance: TObject;
begin
 Result:=Self;
end;

function TVTFIBDataSet.IGetNewID: Integer;
begin
 if Database=nil then
  raise Exception.Create('DataBase not assigned')
 else
 if Trim(AutoUpdateOptions.GeneratorName)='' then
  raise Exception.Create('Generator name undefined')
 else
  Result:=Database.Gen_Id(AutoUpdateOptions.GeneratorName,1)
end;

function TVTFIBDataSet.IGetParamValue(const ParamName: string;
  Value: Variant): Variant;
begin
 Result:=ParamByName(ParamName).Value;
end;

function TVTFIBDataSet.IInsert(const FieldNames, Values: array of variant): boolean;
var
    i:integer;
begin
   for i := 0 to High(FieldNames) do
     QInsert.ParamByName(FieldNames[i]).Value:=Values[i];
   QInsert.ExecQuery;
   Result:=QInsert.RowsAffected>0;
   if Result then
    AutoCommitUpdateTransaction
end;

procedure TVTFIBDataSet.INext;
begin
 Next
end;

procedure TVTFIBDataSet.IOpen;
begin
 Open;
 FetchAll
end;

function TVTFIBDataSet.IParamExist(const ParamName: string): boolean;
begin
 Result:=FindParam(ParamName)<>nil;
end;

function TVTFIBDataSet.IRefresh(const IDParamName: string;
  const Value: Variant; var Return: array of variant): boolean;
begin
 Result:=False 
end;

procedure TVTFIBDataSet.ISetParamValue(const ParamName: string;
  Value: Variant);
begin
 ParamByName(ParamName).Value := Value;
end;

function TVTFIBDataSet.IUpdate(const FieldNames, Values: array of variant): boolean;
var
    i:integer;
    p:TFIBXSQLVAR;
begin
   for i := 0 to High(FieldNames) do
   begin
     p:=QUpdate.FindParam(FieldNames[i]);
     if p<>nil then
      p.Value:=Values[i];
   end;
   QUpdate.ExecQuery;
   Result:=QUpdate.RowsAffected>0;
   if Result then
    AutoCommitUpdateTransaction
end;

end.


