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
unit RDIntfs;

interface

const
   GIDBRetrieveData:TGUID='{450D0BF5-73B9-4C84-BC05-9EBC0A1BB15E}';
   GIDBModifyData  :TGUID='{2FE54B14-BECC-45F7-B5A5-0A8177E778AF}';
   
type
   IDBRetrieveData = interface
   ['{450D0BF5-73B9-4C84-BC05-9EBC0A1BB15E}']
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
   end;

   IDBModifyData = interface
   ['{2FE54B14-BECC-45F7-B5A5-0A8177E778AF}']
    function  IDelete(const IDParamName:string;const Value:Variant):boolean;
    function  IUpdate(const FieldNames,Values:array of variant):boolean;
    function  IInsert(const FieldNames,Values:array of variant):boolean;
    function  IRefresh(const IDParamName:string;const Value:Variant;var Return:array of variant):boolean;
    function  IGetNewId:integer; 
   end;

implementation

end.
