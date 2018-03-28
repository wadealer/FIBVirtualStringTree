{***************************************************************}
{  TDBVirtualStringTree - DB TreeView for Delphi                }
{                                                               }
{    TDBVirtualStringTree is a descendant of                    }
{    TVirtualStringTree component released September 30, 2000   }
{                                                               }
{    It requires VirtualTreeView: www.lischke-online.de         }
{                                                               }
{    Copyright (c) 10.2002 -10.2003 Serge Buzadzhy              }
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

unit DBVirtualStringTree;

interface
{$T-}
uses
  Windows, Messages, SysUtils, Classes, Controls, VirtualTrees,RDIntfs,Dialogs,
  {$IFNDEF VER130}Variants, {$ENDIF}
  Contnrs,ExtCtrls,DB,ActiveX, ImgList;

type

  TDBVirtualStringTree=class;

  TVarArray = array of variant;
  TIntArray = array of integer;
  TStrArray = array of string;

  PVarArray =^TVarArray;
  PStrArray =^TStrArray;
  
  TVTNodeContence = class
  private
    function GetCheckType: TCheckType;
    function GetCheckState: TCheckState;
  protected
    vNode      :PVirtualNode;
    FIdRecord  :integer;
    FValues    : TVarArray;
    FChildCount:integer;
    FInList    :TObjectList;
    FIndexInList:integer;
    FAttemptExpanding:boolean;
  public
    constructor Create(Node:PVirtualNode; List:TObjectList;
     const vValues: TVarArray; vRecordId,vChildCount: Integer
    );
    destructor  Destroy; override;
    property    ChildCount: integer read FChildCount ;
    property    RecordId: integer read FIdRecord;
    property    FieldValues: TVarArray read FValues ;
    property    InExpanding: boolean read FAttemptExpanding;
    property    CheckType  : TCheckType read GetCheckType;
    property    CheckState : TCheckState read GetCheckState;
  end;

  PNodeData = ^TVTNodeContence;

  TDBModifyKind =(dmkInsert,dmkEdit,dmkDelete);
  TDBModifyKinds=set of TDBModifyKind;

  TDBOptions = class (TPersistent)
  private
    FOwner         :TDBVirtualStringTree;
    FCanEdit       :boolean ;
    FIDField       :string;
    FIDParentParam :string;
    FLookFields    :TStrings;
    FInitialParentValue:integer;
    FSource       :IDBRetrieveData;
    FHasChildField:string;
    FAutoCreateColumns:boolean;
    FMaxAutoWidth :integer;
    FDBModifyKinds:TDBModifyKinds;
    procedure SetSource(const Value: IDBRetrieveData);
    procedure SetLookFields(const Value: TStrings);
  public
    constructor Create(AOwner:TDBVirtualStringTree);
    destructor  Destroy ;override;
    function    IsValid:boolean;
  published
    property IDField        :string read FIDField write FIDField;
    property IDParentParam  :string read FIDParentParam write FIDParentParam;
    property LookFields     :TStrings read FLookFields write SetLookFields;
    property HasChildField  :string read FHasChildField write FHasChildField;
    property InitialParentValue:integer read FInitialParentValue write FInitialParentValue default 0;
    property Source        :IDBRetrieveData read FSource write SetSource;
    property AutoCreateColumns:boolean read FAutoCreateColumns write FAutoCreateColumns default false;
    property MaxAutoWidth :integer read FMaxAutoWidth write FMaxAutoWidth default 200;
    property ModifyKinds:TDBModifyKinds read FDBModifyKinds write FDBModifyKinds default [];
  end;

  TVTImageIndexes = class (TPersistent)
  private
   FOwner:TDBVirtualStringTree;
   FExpandedImage  :integer ;
   FCollapsedImage :integer ;
   FChildImage     :integer ;
   FDefaultCheckType:TCheckType;
  public
    constructor Create(AOwner:TDBVirtualStringTree);
    property Owner:TDBVirtualStringTree read FOwner;    
  published
   property ExpandedImage  :integer read FExpandedImage  write FExpandedImage default -1;
   property CollapsedImage :integer read FCollapsedImage write FCollapsedImage default -1;
   property ChildImage     :integer read FChildImage     write FChildImage  default -1  ;
   property CheckTypeDef:TCheckType read FDefaultCheckType write FDefaultCheckType default ctNone;
  end;


  TDBOnChangeCurrentRecord=
   procedure (Sender: TDBVirtualStringTree; RecordId:integer) of object;

  TDBOnFilterRecord=
   procedure (Sender: TDBVirtualStringTree; RecordId:integer;var Accept:boolean) of object;

  TDBOnChangeFilter =
   procedure (Sender: TDBVirtualStringTree;DoFiltered:boolean) of object;

  TDBOnFindNode=
   procedure  (Sender: TDBVirtualStringTree;const Fields:string;
                FilterValues:variant;LocateOptions:TLocateOptions;
                NodeData:TVTNodeContence;
               var DoSearchInChild:boolean
              ) of object;

  TDBOnLocate=
   procedure  (Sender: TDBVirtualStringTree;const Fields:string;
                FilterValues:variant;LocateOptions:TLocateOptions
           ) of object;

  TAfterCopyNode= procedure (SourceNode,TargetNode:PVirtualNode) of object;

  TDBOnEndChecking=procedure(Sender: TDBVirtualStringTree)of object;

  TDBEditState =(esBrowse,esInsert,esEdit,esDelete);


  TDBVirtualStringTree = class(TVirtualStringTree)
  private
   FDBOptions:TDBOptions;
   FContenceList:TObjectList;
   FImageIndexes:TVTImageIndexes;
   FDBOnChangeCurrentRecord:TDBOnChangeCurrentRecord;
   FCheckedNodes:TList;
   FBeforeDeleteRecord:TDBOnChangeCurrentRecord;
   FAfterDeleteRecord:TDBOnChangeCurrentRecord;

   FBeforeEditRecord:TDBOnChangeCurrentRecord;
   FAfterEditRecord:TDBOnChangeCurrentRecord;
   FDBOnFilterRecord:TDBOnFilterRecord;
   FDBBeforeFiltered :TDBOnChangeFilter;
   FDBAfterFiltered  :TDBOnChangeFilter;
   FDBOnFindNode     :TDBOnFindNode;
   FDBBeforeLocate   :TDBOnLocate;
   FDBAfterLocate    :TNotifyEvent;
   FDBAfterCopyNode   :TAfterCopyNode;
   FDefaultValues :TVarArray;
   FDBFiltered    :boolean;
   vTimer:TTimer;
   vEditState:TDBEditState;
   vLastFocusedNode:PVirtualNode;
   vDoCheck:boolean;
   FDBOnEndChecking:TDBOnEndChecking;
   FFindDlg: TFindDialog;
   procedure SetDBOptions(const Value: TDBOptions);
   procedure SetDBFiltered(const Value: boolean);
   procedure ChangeFiltered(const Value: boolean);
   function  GetCheckedCount: Integer;
   procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
   function  GetCheckedNode(Index: integer): PVirtualNode;
  protected
    procedure Notification(AComponent: TComponent;  Operation: TOperation); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoOnDlgFind(Sender:TObject);dynamic;
    procedure DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;  var Text: UnicodeString); override;

    function DoChecking(Node: PVirtualNode; var NewCheckState: TCheckState): boolean;override;

    procedure DoExpanded(Node: PVirtualNode); override;
    function  DoExpanding(Node: PVirtualNode): Boolean; override;
    function  DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal): boolean; override;
    procedure DoFreeNode(Node: PVirtualNode); override;
{
    procedure DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer); override; }

    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList; override;

    procedure DoFocusChange(Node: PVirtualNode; Column: TColumnIndex); override;
    function  DoFocusChanging(OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex): Boolean; override;

    procedure GetNodeValues(Node: PVirtualNode;
     var FieldNames: PVarArray; var Values    : PVarArray
    );

    procedure DoNewText(Node: PVirtualNode; Column: TColumnIndex; Text: UnicodeString); override;
    function  DoNodeCopying(Node, NewParent: PVirtualNode): Boolean; override;


    procedure DoDragDrop(Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint;
      var Effect: Integer; Mode: TDropMode); override;
    function  DoReplaceParent(Node, NewParent: PVirtualNode):Boolean;
    function  DoCreateCopyNode(Node, NewParent: PVirtualNode):PVirtualNode;
    function  DoEndDragging(Mode: TDropMode; Effect:integer):PVirtualNode;



    procedure DoOnScroll(Sender:TObject); dynamic;
    procedure DoOnFilter(Node:PVirtualNode); dynamic;
  protected
    function    CreateContence(ParentNode:PVirtualNode):integer;
    procedure   Resize; override;
  public
    constructor Create(AOwner:TComponent); override;
    destructor  Destroy; override;
    function  DoCancelEdit: Boolean; override;
    procedure   SetCheckTypesToAllNodes(NewCheckType:TCheckType);
    procedure   LoadTree;
    function    LoadChild(ParentNode:PVirtualNode):integer;
    function    ReLoadChild(ParentNode:PVirtualNode):integer;    
    function    RecordId:integer;
    function    ParentId:integer;
    procedure   ExpandParents(Node:PVirtualNode);
    function    FindNode(aRecordId:integer):PVirtualNode; overload;
    function    FindNode(StartNode:PVirtualNode;const Fields:string;FilterValues:variant;LocateOptions:TLocateOptions):PVirtualNode; overload;
    function    NodeId(Node:PVirtualNode):integer;
    function    LocateById(aRecordId:integer):boolean;
    function    Locate(const Fields:string;FilterValues:variant;LocateOptions:TLocateOptions):boolean;
    function    LocateNext(const Fields:string;FilterValues:variant;LocateOptions:TLocateOptions):boolean;
    function    LocateByPath(Path :array of integer):boolean; overload;
    function    LocateByPath(const Path :string):boolean; overload;
    function    FieldValue(const FieldName:string):variant;overload;
    function    FieldValue(Node:PVirtualNode; const FieldName:string):variant;overload;

    function    CacheEdit(aRecordId:integer;
     const Fields: array of variant; const Values:array of variant
    ):boolean;
    function    CacheInsert(aParentId,aRecordId:integer;
     const Fields: array of variant;  const Values:array of variant
    ):PVirtualNode;
    function    CacheDelete(aRecordId:integer):boolean;
    function    ChildExpanding:boolean;
    function    CurrentHasChild:boolean;
    function    NodeHasChild(Node:PVirtualNode):boolean;    
    function    CurrentPath:string;
    function    NodePath(Node:PVirtualNode):string;
    function    ChildsID:TIntArray; overload;
    function    ChildsID(Node:PVirtualNode):TIntArray; overload;
    function    ChildsIDStr:string; overload;
    function    HasCheckedNode:boolean;
    function    DeleteCurrentRecord:boolean;
    procedure   Insert;
    function    IsVisibleRecord(aRecordId:integer):boolean;
    property    DBFiltered    :boolean read FDBFiltered  write SetDBFiltered;
    property    FindDlg: TFindDialog read FFindDlg;
    property    CheckedNode[Index:integer]:PVirtualNode read GetCheckedNode;
    property    CheckedCount:Integer read GetCheckedCount;
    function  CanEdit(Node: PVirtualNode; Column: TColumnIndex): Boolean; override;
  published
    property DBOptions:TDBOptions read FDBOptions write SetDBOptions;
    property ImageIndexes:TVTImageIndexes read FImageIndexes write FImageIndexes;
    property DBOnChangeCurrentRecord:TDBOnChangeCurrentRecord
     read FDBOnChangeCurrentRecord write FDBOnChangeCurrentRecord;
    property DBBeforeDeleteRecord:TDBOnChangeCurrentRecord
     read FBeforeDeleteRecord write FBeforeDeleteRecord;
    property DBAfterDeleteRecord:TDBOnChangeCurrentRecord
     read FAfterDeleteRecord write FAfterDeleteRecord;

    property DBBeforeEditRecord:TDBOnChangeCurrentRecord
     read FBeforeEditRecord write FBeforeEditRecord;
    property DBAfterEditRecord:TDBOnChangeCurrentRecord
     read FAfterEditRecord write FAfterEditRecord;
    property DBOnFilterRecord:TDBOnFilterRecord
     read  FDBOnFilterRecord write FDBOnFilterRecord;
    property DBBeforeFiltered :TDBOnChangeFilter
     read FDBBeforeFiltered  write FDBBeforeFiltered;
    property DBAfterFiltered  :TDBOnChangeFilter
     read FDBAfterFiltered   write FDBAfterFiltered;
    property DBOnFindNode     :TDBOnFindNode
     read FDBOnFindNode      write FDBOnFindNode ;
    property DBBeforeLocate   :TDBOnLocate
     read FDBBeforeLocate      write FDBBeforeLocate ;
    property DBAfterLocate    :TNotifyEvent
     read FDBAfterLocate      write FDBAfterLocate ;
    property DBOnEndChecking:TDBOnEndChecking
     read FDBOnEndChecking write FDBOnEndChecking;
    property DBAfterCopyNode :TAfterCopyNode read FDBAfterCopyNode write FDBAfterCopyNode;
  end;

  TErrorDBTreeCode =(emtCantFindRecord,emtCantFindParent,emtInvalidSource,emtCantEditTree);

  EErrorModifyDBTree=class(Exception)
  public
    constructor Create(ACode:TErrorDBTreeCode);
  end;

  function IdInPath(ID:integer;const Path:string):boolean;



var TreeErrorMessages : array [TErrorDBTreeCode] of string =
(
 'Can''t find Record',
 'Can''t find Parent',
 'Can''t load tree. Source is not valid',
 'Can''t edit tree. Source does not support edit operation'
);

implementation

function IdInPath(ID:integer;const Path:string):boolean;
var SID:string;
begin
  SID:=IntToStr(ID);
  Result:=(SID+'.')=Copy(Path,1,Length(SID+'.'));
  if not Result then
   Result:=('.'+SID)=Copy(Path,Length(Path)-Length(SID+'.')+1,MaxInt);
  if not Result  then
   Result:=Pos('.'+SID+'.',Path)>0;
end;


{ EErrorModifyDBTree }
constructor EErrorModifyDBTree.Create(ACode: TErrorDBTreeCode);
begin
  inherited Create(TreeErrorMessages[ACode]);
end;

{ TVTNodeContence }

constructor TVTNodeContence.Create(Node:PVirtualNode; List:TObjectList;
 const vValues: TVarArray; vRecordId,vChildCount: Integer
);
var
  i: integer;
begin
  inherited Create ;
  vNode       :=Node;
  FChildCount := vChildCount;
  FIdRecord   :=vRecordId;
  FInList     :=List;
  FIndexInList:=List.Add(Self);
  SetLength(FValues,High(vValues)+1);
  for i := 0 to High(vValues)  do
  begin
    FValues[i]:=vValues[i];
  end;
  FAttemptExpanding:=False
end;

destructor TVTNodeContence.Destroy;
begin
  with FInList do
  if (Count>0) then
  begin
    if (FIndexInList<Count-1)  then
    begin
     TVTNodeContence(FInList[Count-1]).FIndexInList:=FIndexInList;
     FInList[FIndexInList]:=FInList[Count-1];
    end;
    Delete(FInList.Count-1);
  end;
  inherited;
end;

function TVTNodeContence.GetCheckState: TCheckState;
begin
 if Assigned(vNode) then
  Result:= vNode.CheckState
 else
  Result:= csUncheckedNormal
end;

function TVTNodeContence.GetCheckType: TCheckType;
begin
 if Assigned(vNode) then
  Result:= vNode.CheckType
 else
  Result:=ctNone
end;

{ TDBVirtualStringTree }

constructor TDBVirtualStringTree.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckImageKind:= ckDarkCheck;  
  FDBOptions   :=TDBOptions.Create(Self) ;
  FContenceList:=TObjectList.Create(False);
  FImageIndexes:=TVTImageIndexes.Create(Self);
  NodeDataSize:=SizeOf(PNodeData);
  vTimer:=TTimer.Create(Self);
  with vTimer do
  begin
   Interval:=300;
   Enabled :=False;
   OnTimer :=DoOnScroll;
  end;
  FDBFiltered:=False;
  FFindDlg   :=TFindDialog.Create(Self);
  FFindDlg.OnFind :=DoOnDlgFind;
  FCheckedNodes   :=TList.Create;
  vDoCheck:=False;  
end;

function  TDBVirtualStringTree.CreateContence(ParentNode:PVirtualNode):integer;
var
  Node: PVirtualNode;
  NodeData:PNodeData;
  ParamValue:Variant ;
  vChildCount:integer;
  vCanCalcChild:boolean;
  i:integer ;
  v:Variant;
  vValues:TVarArray;
begin
 Result:=0;
 if ParentNode<>nil then
 begin
  NodeData    := GetNodeData(ParentNode);
  if not Assigned(NodeData) or not Assigned(NodeData^) then Exit;
  ParamValue  := NodeData.FIdRecord;
 end
 else
  ParamValue  :=FDBOptions.FInitialParentValue;
 with FDBOptions,FDBOptions.FSource do
 begin
   IClose;
   ISetParamValue(FIDParentParam,ParamValue);
   IOpen;
   vCanCalcChild:=IFieldExist(FHasChildField);
   vChildCount:=0;
   SetLength(vValues,FLookFields.Count);
   while not IEof do
   begin
     Node        := AddChild(ParentNode);
     NodeData    := GetNodeData(Node);
     if vCanCalcChild then
     begin
      v:=IGetFieldValue(FHasChildField);
      if VarIsNull(v) then
       vChildCount:=0
      else
       vChildCount:=v;
     end;
     if vChildCount>0 then
       Include(Node^.States, vsHasChildren);
     for i := 0 to FLookFields.Count - 1 do
     begin
      vValues[i]:=IGetFieldValue(FLookFields[i]);
     end;
     NodeData^ :=
      TVTNodeContence.Create(Node,FContenceList,vValues,IGetFieldValue(FIDField), vChildCount);
     Node.CheckType:= FImageIndexes.FDefaultCheckType;
     if Assigned(ParentNode) then
      if (ParentNode.CheckType=ctTriStateCheckBox)
       and (ParentNode.CheckState in [csCheckedNormal,csCheckedPressed])
      then
      begin
       Node.CheckState:=csCheckedNormal;
       FCheckedNodes.Add(Node);
      end;
     if FDBFiltered then DoOnFilter(Node);
     Inc(Result);
     INext
   end;
 end;
end;


destructor TDBVirtualStringTree.Destroy;
begin
  FContenceList.Free;
//  FDBOptions.Free;
  FreeAndNil(FDBOptions);
  FImageIndexes.Free;
  FCheckedNodes.Free;
  inherited;
end;

procedure TDBVirtualStringTree.DoExpanded(Node: PVirtualNode);
begin
  inherited;
end;

function TDBVirtualStringTree.DoExpanding(Node: PVirtualNode): Boolean;
var
  NodeData:PNodeData;
begin
  if Assigned(Node)  then
  if not HasChildren[Node]  then
  begin
    if LoadChild(Node)=0 then
    begin
     NodeData    := GetNodeData(Node);
     if Assigned(NodeData) then
       NodeData^.FAttemptExpanding:=True       
    end;
  end;
  Result:=inherited DoExpanding(Node)
end;

procedure TDBVirtualStringTree.DoFocusChange(Node: PVirtualNode;
  Column: TColumnIndex);
begin
 if Assigned(FDBOnChangeCurrentRecord) then
 begin
  vTimer.Enabled:=False;
  vTimer.Enabled:=True;
 end;
 inherited;
end;

function  TDBVirtualStringTree.DoFocusChanging(OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex): Boolean;
var
  Data: PNodeData;
begin
  if Assigned(OldNode) and (OldNode<>NewNode) then
  begin
   Data := GetNodeData(OldNode);
   Data ^.FAttemptExpanding:=False;
  end;
  Result:= inherited
   DoFocusChanging(OldNode, NewNode,OldColumn, NewColumn);
end;

procedure TDBVirtualStringTree.DoFreeNode(Node: PVirtualNode);
var
  Data: PNodeData;
begin
  Data := GetNodeData(Node);
  if Assigned(Data) and Assigned(Data^) then
    Data^.Free;
  inherited DoFreeNode(Node);
end;

{
procedure TDBVirtualStringTree.DoGetImageIndex(Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var Index: Integer);
var
  Data :PNodeData;
begin
  if Kind<>ikOverlay then
  if Column<=0 then
  begin
    Data := GetNodeData(Node);
    if Assigned(Data) and Assigned(Data^) then
    if (Data^.ChildCount>0) then
     if vsExpanded in Node^.States then
        Index:= FImageIndexes.FExpandedImage
     else
        Index:= FImageIndexes.FCollapsedImage
    else
    if Data^.FAttemptExpanding and (dmkInsert in FDBOptions.ModifyKinds) then
     Index:= FImageIndexes.FExpandedImage
    else
     Index:= FImageIndexes.FChildImage;
  end;
  inherited;
end;  }

procedure TDBVirtualStringTree.DoGetText(Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var Text: UnicodeString);
var
  Data: PNodeData;
  v   : variant ;
begin
  Data := GetNodeData(Node);
  if Assigned(Data) and Assigned(Data^) then
  begin
   if (Column<=High(Data^.FValues)) then
   begin
    if Column<0 then
     v   :=Data^.FValues[0]
    else
     v   :=Data^.FValues[Column];
    if VarIsNull(v) then
     Text := ''
    else
     Text :=v;
   end;
  end;
  inherited;
end;

function TDBVirtualStringTree.DoInitChildren(Node: PVirtualNode;
  var ChildCount: Cardinal): boolean;
begin
 ChildCount:=LoadChild(Node);
 Result := inherited;
end;

function    TDBVirtualStringTree.LoadChild(ParentNode: PVirtualNode):integer;
var
 Data: PNodeData;
begin
 if Assigned(ParentNode) then
 begin
   Data := GetNodeData(ParentNode);
   Result:=ChildCount[ParentNode];
   if (Result=0) and (Data^.ChildCount<>0) then
    Result:=CreateContence(ParentNode);
 end
 else
   Result:=0
end;

function TDBVirtualStringTree.ReLoadChild(ParentNode:PVirtualNode):integer;
var
  vExpanded:boolean;
begin
  if Assigned(ParentNode) then
  begin
   vExpanded:=vsExpanded in ParentNode^.States;
   DeleteChildren(ParentNode);
   Result:=LoadChild(ParentNode);
   if vExpanded and not (vsExpanded in ParentNode^.States) then
    ToggleNode(ParentNode);     
  end
  else
    Result := 0;

end;

procedure TDBVirtualStringTree.SetCheckTypesToAllNodes(NewCheckType:TCheckType);
var
  i: Integer;
begin
  for i := 0 to FContenceList.Count - 1 do
    with TVTNodeContence(FContenceList[i]) do
    if Assigned(vNode) then
    begin
      vNode.CheckType:=NewCheckType
    end;
end;

procedure TDBVirtualStringTree.LoadTree;
var
 i,j :integer;
 vc:TVirtualTreeColumn;
 OldFiltered:boolean;
 Created:boolean;
begin
 FCheckedNodes.Clear;
 OldFiltered:=DBFiltered;
 vEditState:=esBrowse;
 Clear;
 if not FDBOptions.IsValid then
  raise Exception.Create(TreeErrorMessages[emtInvalidSource]);
 DBFiltered:=False;

 if FDBOptions.FAutoCreateColumns then
 begin
//  Header.Columns.Clear;
  if Header.Columns.Count<FDBOptions.FLookFields.Count then
  with FDBOptions do
  for i := 0 to FLookFields.Count - 1 do
  begin
   Created:=i>=Header.Columns.Count ;
   if Created then
    vc       :=Header.Columns.Add
   else
    vc:=Header.Columns[i];
   vc.Text  :=FDBOptions.FSource.IDisplayFieldName(FLookFields[i]);
   if Created then
   begin
     j        :=FDBOptions.FSource.IFieldWidth(FLookFields[i]);
     if j=1 then
     begin
       vc.MaxWidth:=1;
       vc.MinWidth:=0;
       Dec(j);
     end;
     vc.Width :=25*j;
     if vc.Width>FMaxAutoWidth then
      vc.Width :=FMaxAutoWidth;
   end;
  end;
  SetLength(FDefaultValues,FDBOptions.FLookFields.Count );
 end;
 NodeDataSize:=SizeOf(PNodeData);
 CreateContence(nil);
 if hoAutoResize in Header.Options then
 begin
  Header.Options:= Header.Options-[hoAutoResize];
  Header.Options:= Header.Options+[hoAutoResize];
 end;
 if  OldFiltered then
  DBFiltered:=OldFiltered;
end;

procedure TDBVirtualStringTree.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  IC:IDBRetrieveData;
  DSAsCmp:TObject;
begin
  inherited;
  if (Operation=opRemove) and Assigned(FDBOptions) then
  if Supports(FDBOptions.FSource,GIDBRetrieveData,IC) then
  begin
   DSAsCmp:=IC.IGetInstance;
   if DSAsCmp=AComponent then
    FDBOptions.FSource:=nil
  end;
end;

procedure TDBVirtualStringTree.SetDBOptions(const Value: TDBOptions);
begin
  FDBOptions.Assign( Value);
end;

function TDBVirtualStringTree.RecordId: integer;
var
  Data: PNodeData;
begin
  Result:=FDBOptions.FInitialParentValue;
  if Assigned(FocusedNode) then
  begin
   Data := GetNodeData(FocusedNode);
   if Assigned(Data) and Assigned(Data^) then
    Result:=Data^.FIdRecord
  end;
end;

function  TDBVirtualStringTree.NodeId(Node:PVirtualNode):integer;
var
  Data: PNodeData;
begin
  Result:=FDBOptions.FInitialParentValue;
  if Assigned(Node) then
  begin
   Data := GetNodeData(Node);
   if Assigned(Data) and Assigned(Data^) then
    Result:=Data^.FIdRecord
  end;
end;

function TDBVirtualStringTree.ParentId: integer;
var
  Data: PNodeData;
begin
  Result:=FDBOptions.InitialParentValue;
  if Assigned(FocusedNode)  and Assigned(FocusedNode.Parent) then
  begin
   Data := GetNodeData(FocusedNode.Parent);
   if Assigned(Data) and Assigned(Data^) then
    Result:=Data^.FIdRecord
  end;
end;

procedure   TDBVirtualStringTree.ExpandParents(Node:PVirtualNode);
begin
  if not Assigned(Node) then
   Exit;
  while Assigned(Node.Parent) do
  begin
   if not Expanded[Node.Parent] then
    Expanded[Node.Parent]:=True;
   Node:=Node.Parent
  end;
end;

function  TDBVirtualStringTree.FindNode(aRecordId:integer):PVirtualNode;
var i:integer;
begin
 Result:=nil;
 with FContenceList do
 for i :=Count - 1  downto 0 do
 begin
   if TVTNodeContence(FContenceList[i]).FIdRecord =aRecordId then
   begin
     Result:=TVTNodeContence(FContenceList[i]).vNode ;
     Exit;
   end;
 end;
end;

function TDBVirtualStringTree.LocateById(aRecordId: integer): boolean;
var
   TargetNode:PVirtualNode;
begin
 TargetNode:=FindNode(aRecordId);
 Result:= Assigned(TargetNode) ;
 if Result then
 begin
//   ExpandParents(TargetNode);
   FocusedNode:=TargetNode;
   Selected[TargetNode]:=True;
   ScrollIntoView(FocusedNode,True);
 end;
end;

function  TDBVirtualStringTree.LocateByPath(Path :array of integer):boolean;
var  i,j:integer;
    expandedId:array of integer;
    TargetNode:PVirtualNode;
begin
 BeginUpdate;
 TargetNode:=FindNode(Path[High(Path)]);
 Result:=TargetNode<>nil;
 j:=0;
 try
   if not Result then
   for i := 0 to High(Path) do
   begin
     if Path[i]=FDBOptions.FInitialParentValue then Continue;

     TargetNode :=FindNode(Path[i]);
     if TargetNode<>nil then
     begin
       if i=High(Path) then
       begin
         Result:=True; Break;
       end
       else
       begin
         if not Expanded[TargetNode] then
         begin
           Inc(j);
           SetLength(expandedId,j);
           expandedId[j-1]:=NodeId(TargetNode);
         end;
         Expanded[TargetNode]:=True;
         if not Expanded[TargetNode] then
         begin
           Result:=False;
           Break
         end;
       end;
     end
     else
       begin
         Result:=False;
         Break
       end;
   end;
 finally
  if Result then
  begin
   FocusedNode:=TargetNode;
   Selected[TargetNode]:=True;
  end
  else
  begin
   for i:=j-1 downto 0 do
   begin
    Expanded[FindNode(expandedId[i])]:=False;
   end;
  end;
  EndUpdate;
  ScrollIntoView(FocusedNode,True);
 end;
end;

function TDBVirtualStringTree.DoEndDragging(Mode: TDropMode; Effect:integer):PVirtualNode;
var
  i: Integer;
  Nodes:TNodeArray;
  NewParent:PVirtualNode;
begin
  Result:=nil;
  Nodes:=DragSelection;
  case Mode of
    dmAbove,dmBelow: NewParent:=DropTargetNode.Parent ;
    dmOnNode       : NewParent:=DropTargetNode ;
  else
    Exit;
  end;
  for I := 0 to High(Nodes) do
   if not HasAsParent(NewParent, Nodes[I]) then
   case Effect of
    DROPEFFECT_COPY:
    begin
     Result:=DoCreateCopyNode(Nodes[I],NewParent);
    end;
    DROPEFFECT_MOVE:
    begin
      DoReplaceParent(Nodes[I],NewParent);
      Result:=Nodes[I]
    end;
   end;
end;

procedure TDBVirtualStringTree.DoDragDrop(Source: TObject; DataObject: IDataObject;
  Formats: TFormatArray; Shift: TShiftState; Pt: TPoint;
      var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  AttachMode: TVTNodeAttachMode;
  ResNode:PVirtualNode;
begin
  if Assigned(OnDragDrop) then
  begin
    OnDragDrop(Self, Source, DataObject, Formats, Shift, Pt, Effect, Mode);
    Exit;
  end;
// Default Drop procedure  
  if Length(Formats) > 0 then
  begin
    // OLE drag'n drop
    // If the native tree format is listed then use this and accept the drop, otherwise recject (ignore) it.
    // It is recommend by Microsoft to order available clipboard formats in decreasing detail richness so
    // the first best format which we can accept is usually the best format we can get at all.
    for I := 0 to High(Formats) do
      if Formats[I] = CF_VIRTUALTREE then
      begin
        case Mode of
          dmAbove:
            AttachMode := amInsertBefore;
          dmOnNode:
            AttachMode := amAddChildLast;
          dmBelow:
            AttachMode := amInsertAfter;
        else
          if Assigned(Source) and (Source is TBaseVirtualTree) and (Self <> Source) then
            AttachMode := amInsertBefore
          else
            AttachMode := amNowhere;
        end;                            
        // in the case the drop target does an optimized move Effect is set to DROPEFFECT_NONE
        // to indicate this also to the drag source (so the source doesn't need to take any further action)
        BeginUpdate;
        try
         ResNode:=DoEndDragging(Mode,Effect);
         ProcessDrop(DataObject, DropTargetNode, Effect, AttachMode);
         if Effect =DROPEFFECT_MOVE then
          ScrollIntoView(FocusedNode,True)
         else
         begin
          ScrollIntoView(ResNode,True);
          FocusedNode:=ResNode
         end;
        finally
         EndUpdate;
        end;
        Break;
      end;
  end
  else
  begin
    // VCL drag'n drop, Effects contains by default both move and copy effect suggestion,
    // as usual the application has to find out what operation is finally to do
    Beep
  end;
end;




function  TDBVirtualStringTree.DoReplaceParent(Node, NewParent: PVirtualNode):Boolean;
var
  OldParentData: PNodeData;
  ParentData: PNodeData;
  NodeData  : PNodeData;
  OldParent : PVirtualNode;
begin
  Result := True;
  ParentData:= GetNodeData(NewParent);
  NodeData  := GetNodeData(Node);
  if Assigned(NodeData) and Assigned(ParentData)then
  begin
    LoadChild(NewParent);
    OldParent  :=Node.Parent;
    try
     Node.Parent:=NewParent;
     DoNewText(Node, 0, NodeData^.FValues[0]);
     Node.Parent:=OldParent;
    except
     Node.Parent:=OldParent;
     Result := False;
     Exit;
    end;
    OldParentData:= GetNodeData(Node.Parent);
    if Assigned(OldParentData) then
     OldParentData^.FChildCount:=OldParentData^.FChildCount-1;
    ParentData^.FChildCount:=ParentData^.FChildCount+1;
  end;
end;

function  TDBVirtualStringTree.DoCreateCopyNode(Node, NewParent: PVirtualNode):PVirtualNode;
var

  vParentId    :integer;
  vCopyRecId   :integer;
  ParentData: PNodeData;
  NodeData  : PNodeData;
  FieldNames: array of variant;
  Values    : array of variant;
  pFieldNames:PVarArray;
  pValues: PVarArray;

begin
  Result := nil;
  ParentData:= GetNodeData(NewParent);
  NodeData  := GetNodeData(Node);
  if Assigned(NodeData) and Assigned(ParentData)then
  begin
   Expanded[NewParent]:=True;
   vCopyRecId:=(FDBOptions.FSource as IDBModifyData).IGetNewId;
   vParentId :=NodeId(NewParent);
   pFieldNames:=@FieldNames;
   pValues    :=@Values;
   GetNodeValues(Node,pFieldNames, pValues);
   Values[0]:=vCopyRecId;
   Values[1]:=vParentId;
   Result:=CacheInsert(vParentId,vCopyRecId,FieldNames, Values);
   (FDBOptions.FSource as IDBModifyData).IInsert(FieldNames,Values);
   
   if Assigned(FDBAfterCopyNode) then
    FDBAfterCopyNode(Node,Result);     
  end;
end;

function  TDBVirtualStringTree.DoNodeCopying(Node, NewParent: PVirtualNode): Boolean;
begin
 inherited DoNodeCopying(Node, NewParent);
 Result := False;
end;

function TDBVirtualStringTree.CanEdit(Node: PVirtualNode;
  Column: TColumnIndex): Boolean;
begin
 Result:=inherited CanEdit(Node,  Column);
 if Result then
  Result:=Assigned(FDBOptions.Source) and (FDBOptions.FCanEdit)
end;


procedure TDBVirtualStringTree.GetNodeValues(Node: PVirtualNode;
 var FieldNames: PVarArray;
 var Values    : PVarArray
);
var
  Data,ParentData: PNodeData;
  ParentId       : integer;
  i              : integer;
begin
      Data := GetNodeData(Node);
      if not (Assigned(Data) and Assigned(Data^)) then Exit;
      ParentData:=GetNodeData(Node^.Parent);
      if Assigned(ParentData) and Assigned(ParentData^) then
       ParentId:=ParentData^.FIdRecord
      else
       ParentId:=FDBOptions.InitialParentValue;

      SetLength(FieldNames^,FDBOptions.FLookFields.Count+2);
      SetLength(Values^,FDBOptions.FLookFields.Count+2);
      FieldNames^[0]:= FDBOptions.FIDField;
      Values^[0]:=IntToStr(Data^.FIdRecord);
      FieldNames^[1]:= FDBOptions.FIDParentParam;
      Values^[1]:=IntToStr(ParentId);

      for i := 2 to FDBOptions.FLookFields.Count+1  do
      begin
        FieldNames^[i]:=FDBOptions.FLookFields[i-2];
        Values^[i]:=Data^.FValues[i-2]
      end;
end;

procedure TDBVirtualStringTree.DoNewText(Node: PVirtualNode;
  Column: TColumnIndex; Text: UnicodeString);
var
  Data: PNodeData;
  FieldNames:array of variant;
  Values: array of variant;
  pFieldNames:PVarArray;
  pValues: PVarArray;

begin
  if FDBOptions.FCanEdit and (dmkEdit in FDBOptions.ModifyKinds)  then
  begin
    Data := GetNodeData(Node);
    if not (Assigned(Data) and Assigned(Data^)) then Exit;
    pFieldNames:=@FieldNames;
    pValues    :=@Values;
    GetNodeValues(Node,pFieldNames, pValues);
    Values[Column+2]:=Text;
    if vEditState=esInsert then
    begin
     (FDBOptions.FSource as IDBModifyData).IInsert(FieldNames,Values)
    end
    else
    begin
      if Assigned(FBeforeEditRecord) then FBeforeEditRecord(Self,RecordId);
      (FDBOptions.FSource as IDBModifyData).IUpdate(FieldNames,Values);
      if Assigned(FAfterEditRecord) then  FAfterEditRecord(Self,RecordId);
    end;
    Data^.FValues[Column]:=Text;
    vEditState:=esBrowse;
  end;
  inherited;
end;

function    TDBVirtualStringTree.CacheInsert(aParentId,aRecordId:integer;
     const Fields: array of variant;  const Values:array of variant
    ):PVirtualNode;
var
 Parent: PVirtualNode;
 Node  : PVirtualNode;
 Data  : PNodeData;
 i,j   :integer;
 vValues:TVarArray;
begin
 Result:=nil;
 if (aParentId=FDBOptions.FInitialParentValue) or LocateById(aParentId) then
 begin
   if aParentId=FDBOptions.FInitialParentValue then
     Parent:=nil
   else
     Parent:=FocusedNode;
  New(Data);
  Node := AddChild(Parent,Data);
  Data := GetNodeData(Node);
  if not Assigned(Data) or not Assigned(Data^) then  Exit;
  SetLength(vValues,FDBOptions .FLookFields.Count);
  with FDBOptions do
  for i := 0 to High(Fields) do
  begin
     j:=FLookFields.IndexOf(Fields[i]);
     if j>-1 then
     begin
       vValues[j]:=Values[i];
     end;
  end;
  Data^:=TVTNodeContence.Create(Node,FContenceList,vValues,aRecordId,0);
  if Parent<>nil then
  begin
   Data := GetNodeData(Parent);
   Data^.FChildCount:=Data^.ChildCount+1;
  end;
  Result:=Node  
 end
 else
  raise EErrorModifyDBTree.Create(emtCantFindParent);
end;

function TDBVirtualStringTree.CacheDelete(aRecordId:integer):boolean;
var
 ParentData  : PNodeData;
 NewPos: PVirtualNode; 
begin
 if LocateById(aRecordId) then
 begin
  NewPos:=GetNextVisibleSibling(FocusedNode);
  if not Assigned(NewPos) then
   NewPos:=GetPreviousVisibleSibling(FocusedNode);
  if not Assigned(NewPos) then
   NewPos:=FocusedNode.Parent;

  ParentData  :=GetNodeData(FocusedNode.Parent);
  if Assigned(ParentData) then
   Dec(ParentData^.FChildCount);
  DeleteNode(FocusedNode);
   if Assigned(NewPos) then
   begin
    FocusedNode:=NewPos;
    Selected[FocusedNode]:=True;
   end;
  Result:=True;
 end
 else
   Result:=False;
end;

function TDBVirtualStringTree.CacheEdit(aRecordId:integer;
     const Fields: array of variant; const Values:array of variant
    ):boolean;
var
  i,j: Integer;
  Node:PVirtualNode;
  Data: PNodeData;
begin
 Result := False;
 Node:=FocusedNode;
 with FDBOptions do
 if LocateById(aRecordId) then
 try
   Data := GetNodeData(FocusedNode);
   if not Assigned(Data) or not Assigned(Data^) then Exit;
    for i := 0 to High(Fields) do
    begin
       j:=FLookFields.IndexOf(Fields[i]);
       if j>-1 then
       begin
        Data^.FValues[j]:=Values[i];
       end;
    end;
   Result := True;
 finally
  FocusedNode:=Node;
 end
 else
  raise EErrorModifyDBTree.Create(emtCantFindRecord);
end;

function TDBVirtualStringTree.ChildExpanding: boolean;
var
  Data: PNodeData;
begin
  if Assigned(FocusedNode)  then
  begin
   Result:=vsExpanded in FocusedNode.States;
   if not Result then
   begin
    Data := GetNodeData(FocusedNode);
    Result:=Data^.FAttemptExpanding
   end;
  end
  else
   Result:=False
end;

procedure TDBVirtualStringTree.DoOnScroll(Sender: TObject);
var
  Data: PNodeData;
begin
 try
  vTimer.Enabled:=False;
  if FocusedNode<>vLastFocusedNode then
  if Assigned(FDBOnChangeCurrentRecord)
  and Assigned(FocusedNode)  then
  begin
   Data := GetNodeData(FocusedNode);
   if Assigned(Data) and Assigned(Data^) then
    FDBOnChangeCurrentRecord(Self,Data^.RecordId);
  end;
  vLastFocusedNode:=FocusedNode;
  inherited;
 finally
   vTimer.Enabled:=False;
 end
end;


function TDBVirtualStringTree.DeleteCurrentRecord: boolean;
var
   id    :integer;
begin
  with FDBOptions do
   if FCanEdit and (dmkDelete in ModifyKinds) and (Assigned(FocusedNode)) then
   begin
    id    :=RecordId;
    if Assigned(FBeforeDeleteRecord) then FBeforeDeleteRecord(Self,id);
    Result:=(FSource as IDBModifyData).IDelete(FIDField,id);
    if Result then
    begin
     CacheDelete(id);
     if Assigned(FAfterDeleteRecord) then FAfterDeleteRecord(Self,id);
    end;
   end
   else
    Result := False;
end;


procedure TDBVirtualStringTree.Insert;
var
  Node: PVirtualNode;
  NodeData:PNodeData;
  NewId:integer;
  am:TVTNodeAttachMode;
begin
  NewId:=(FDBOptions.FSource as IDBModifyData).IGetNewId;
  Node:=FocusedNode;
  am:=amAddChildLast;  
  if Assigned(Node) then
  begin
    NodeData:=GetNodeData(Node);
   if Assigned(NodeData) and Assigned(NodeData^) then
    if (NodeData^.FAttemptExpanding or (vsExpanded in Node^.States)) then
    begin
     am:=amAddChildLast;
    end
    else
    begin
     am:=amInsertBefore;
     NodeData  := GetNodeData(Node.Parent);
    end;

   if Assigned(NodeData) and Assigned(NodeData^) then
    NodeData^.FChildCount:=NodeData^.FChildCount+1
  end;
  Node      :=InsertNode(Node,am);
  NodeData  := GetNodeData(Node);
  NodeData^ := TVTNodeContence.Create(Node,FContenceList,FDefaultValues,NewId,0);
  vEditState:=esInsert;

  Selected[Node]:=True;
  EditNode(Node,0)
end;

function TDBVirtualStringTree.DoCancelEdit: Boolean;
var
   NewPos: PVirtualNode;
   DN    : PVirtualNode;
   NodeData:PNodeData;
begin
 Result:=inherited DoCancelEdit;
 if Result and (vEditState=esInsert) then
 begin
  if Assigned(FocusedNode.Parent) then
  begin
    NodeData:=GetNodeData(FocusedNode.Parent);
    if Assigned(NodeData) and Assigned(NodeData^) then
     NodeData^.FChildCount:=NodeData^.FChildCount-1;
  end;

  NewPos:=GetNextSibling(FocusedNode);
  if not Assigned(NewPos) then NewPos:=GetPreviousSibling(FocusedNode);
  if not Assigned(NewPos) then NewPos:=FocusedNode.Parent;
  DN:=FocusedNode;
  if Assigned(NewPos) then
  begin
   FocusedNode:=NewPos;
   Selected[FocusedNode]:=True;
  end
  else
   FocusedNode:=nil;
  DeleteNode(DN);
  vEditState:=esBrowse;
  SetFocus
 end;
end;

function TDBVirtualStringTree.CurrentHasChild: boolean;
begin
 Result := 
  NodeHasChild(FocusedNode);
end;

function TDBVirtualStringTree.NodeHasChild(Node:PVirtualNode):boolean;
var
   NodeData:PNodeData;
begin
 Result := False;
 if Assigned(Node) then
 begin
   NodeData:=GetNodeData(Node);
   if Assigned(NodeData) and Assigned(NodeData^) then
    Result:=NodeData^.FChildCount>0
 end;
end;

function  TDBVirtualStringTree.NodePath(Node:PVirtualNode):string;
var
   TempNode:PVirtualNode;
   NodeData:PNodeData;
begin
 Result :='';
 TempNode:=Node;
 while Assigned(TempNode) do
 begin
   NodeData:=GetNodeData(TempNode);
   if Assigned(NodeData) and Assigned(NodeData^) then
   begin
     if TempNode<>Node then
      Result:=IntToStr(NodeData^.FIdRecord)+'.'+Result
     else
      Result:=IntToStr(NodeData^.FIdRecord);
     TempNode:=TempNode.Parent
   end
   else
     TempNode:=nil
 end;
 Result :=IntToStr(FDBOptions.FInitialParentValue)+'.'+Result;
end;

function TDBVirtualStringTree.CurrentPath: string;
begin
 Result :=NodePath(FocusedNode);
end;

function  TDBVirtualStringTree.ChildsID:TIntArray;
begin
  Result:=ChildsID(FocusedNode)
end;

function  TDBVirtualStringTree.ChildsID(Node:PVirtualNode):TIntArray;
var
  i:integer;
  CurChild:PVirtualNode;
  NodeData:PNodeData;
begin
  if not Assigned(Node) then
  begin
   SetLength(Result,0);
   Exit;
  end;
  LoadChild(Node);
  SetLength(Result,ChildCount[Node]);
  CurChild:= Node.FirstChild;
  i:=0;
  while Assigned(CurChild) do
  begin
    NodeData:=GetNodeData(CurChild);
    if Assigned(NodeData) then
      Result[i]:=NodeData^.FIdRecord
    else
      Result[i]:=0;
    Inc(i);
    CurChild:= CurChild.NextSibling;
  end;
end;

procedure TDBVirtualStringTree.DoOnFilter(Node:PVirtualNode);
var
 Accept:boolean;
 NodeData:PNodeData;
begin
 if not Assigned(Node) then Exit;  
 if Assigned(FDBOnFilterRecord) then
 begin
   Accept:=True;
   NodeData:=GetNodeData(Node);
   if Assigned(NodeData) and Assigned(NodeData^) then
   begin
     FDBOnFilterRecord(Self,NodeData^.RecordId,Accept);
     IsVisible[Node]:=Accept;
   end;
 end;
end;

procedure TDBVirtualStringTree.SetDBFiltered(const Value: boolean);
begin
  if Value<>FDBFiltered then
  begin
   if Assigned(FDBBeforeFiltered) then
    FDBBeforeFiltered(Self,Value);
    FDBFiltered := Value;
    ChangeFiltered(Value);
   if Assigned(FDBAfterFiltered) then
    FDBAfterFiltered(Self,Value);

  end;
end;

procedure TDBVirtualStringTree.ChangeFiltered(const Value: boolean);
var
 i:integer;
begin
 BeginUpdate;
 try
   for i := 0 to Pred(FContenceList.Count) do
   with TVTNodeContence(FContenceList[i]) do
   begin
     if Value then
      DoOnFilter(vNode)
     else
      IsVisible[vNode]:=True;
   end;
 finally
   EndUpdate;
   Invalidate
 end;
end;

function TDBVirtualStringTree.Locate(const Fields: string;
  FilterValues: variant; LocateOptions: TLocateOptions): boolean;
var
   TargetNode:PVirtualNode;
begin
 if Assigned(FDBBeforeLocate) then
  FDBBeforeLocate(Self,Fields,FilterValues,LocateOptions);
 TargetNode:=FindNode(nil,Fields,FilterValues,LocateOptions);
 Result:= Assigned(TargetNode) ;
 if Result then
 begin
   FocusedNode:=TargetNode;
   Selected[TargetNode]:=True;
   ScrollIntoView(FocusedNode,True);
 end;
 if Assigned(FDBAfterLocate) then FDBAfterLocate(Self);
end;

function TDBVirtualStringTree.LocateNext(const Fields:string;FilterValues:variant;
 LocateOptions:TLocateOptions
):boolean;
var
   TargetNode:PVirtualNode;
begin
 if Assigned(FDBBeforeLocate) then
  FDBBeforeLocate(Self,Fields,FilterValues,LocateOptions);
 TargetNode:=FindNode(FocusedNode,Fields,FilterValues,LocateOptions);
 Result:= Assigned(TargetNode) ;
 if Result then
 begin
   FocusedNode:=TargetNode;
   Selected[TargetNode]:=True;
   ScrollIntoView(FocusedNode,True);
 end;
 if Assigned(FDBAfterLocate) then FDBAfterLocate(Self); 
end;


function TDBVirtualStringTree.FindNode(StartNode:PVirtualNode;
  const Fields: string; FilterValues: variant; LocateOptions: TLocateOptions
): PVirtualNode;
var
 IndField:integer;
 isStrVal:boolean;
 FS:Variant;
 CurNode,Node:PVirtualNode;
 NodeData:PNodeData;
 DoExam  :boolean;

function IsTargetNode(N:TVTNodeContence):boolean;
var TS:Variant;
begin
 if IndField>=0 then
 begin
   if isStrVal then
   if (loCaseInsensitive  in LocateOptions) then
    TS:=AnsiUpperCase(N.FValues[IndField])
   else
    TS:=N.FValues[IndField];
   Result:= TS=FS;
   if not Result and (isStrVal) then
    if(loPartialKey in LocateOptions) then
      Result:=Pos(FS,TS)>0
 end
 else
  Result:=N.FIdRecord=FS
end;

begin
 { TODO -oBUZZ : Tomorrow make find for Many Fields }
{ if Fields=DBOptions.FIDField then
 begin
  if LocateByID(FilterValues) then
   Result:=FocusedNode
  else
   Result := nil;
  Exit;
 end;
}
 IndField:=FDBOptions.FLookFields.IndexOf(Fields);
 isStrVal:=VarType(FilterValues) =varString;
 if isStrVal and (loCaseInsensitive  in LocateOptions) then
  FS:=AnsiUpperCase(FilterValues)
 else
  FS:=FilterValues;
 Result := nil;
 if (IndField>=0) or (Fields=DBOptions.FIDField) then
 begin
   Node:=nil;
   if Assigned(FDBOnFindNode) and (StartNode<>nil) then
   begin
     DoExam  :=True;
     FDBOnFindNode(Self,Fields,FilterValues,LocateOptions,PNodeData(GetNodeData(StartNode))^,DoExam );
     if  DoExam then
       Node:=GetFirstVisibleChild(StartNode);
   end
   else
    Node:=GetFirstVisibleChild(StartNode);
    if not Assigned(Node) then
     if not Assigned(StartNode) then
      Exit
     else
     begin
       if StartNode.Parent=RootNode then
         Exit
       else
       Node:=GetNextVisibleSibling(StartNode);
       if Assigned(Node)  then
       begin
        NodeData:=GetNodeData(Node);
        if not Assigned(NodeData) or not Assigned(NodeData^) then Exit;
        if IsTargetNode(NodeData^) then
        begin
          Result:=Node; Exit;
        end;
       end;  
     end;
    CurNode:=StartNode;
    while not Assigned(Node) and Assigned(CurNode.Parent) do
    begin
     if CurNode.Parent=RootNode then    Exit;       
     Node:=GetNextVisibleSibling(CurNode.Parent);
     CurNode:=CurNode.Parent
    end;
   while Assigned(Node) do
   begin
    NodeData:=GetNodeData(Node);
    if not Assigned(NodeData) or not Assigned(NodeData^) then Exit;
    if IsTargetNode(NodeData^) then
    begin
      Result:=Node; Exit;
    end
    else
    begin
      CurNode:=Node;
      DoExam  :=True;
      if Assigned(FDBOnFindNode) then
         FDBOnFindNode(Self,Fields,FilterValues,LocateOptions,NodeData^,DoExam );
      if HasChildren[Node] and (DoExam) then
      begin
       Node:=GetFirstVisibleChild(Node);
      end
      else
       Node:=nil;
     if not Assigned(Node) then
       Node:=GetNextVisibleSibling(CurNode);
      while  not Assigned(Node) and Assigned(CurNode.Parent) do
      begin
        if CurNode.Parent=RootNode then    Exit;

         Node:=GetNextVisibleSibling(CurNode.Parent);
        CurNode:=CurNode.Parent
      end;
    end;
   end;
 end;
end;

function TDBVirtualStringTree.IsVisibleRecord(aRecordId: integer): boolean;
var
 Node:PVirtualNode;
begin
 Node:=FindNode(aRecordId);
 if Assigned(Node) then
   Result := vsVisible in Node^.States
 else
   Result := False;
end;

function TDBVirtualStringTree.LocateByPath(const Path: string): boolean;
var
    IDs:array of integer;
    i,L,j,k:integer;
begin
   L:=Length(Path);
   if L=0 then
   begin
     Result := False; Exit;
   end;
   i:=1;
   while (Path[i]='.') and (i<=L) do Inc(i);
   if i>L then
    Result:=False
   else
   begin
     j:=i; k:=1;
     SetLength(IDs,k);
     while (i<=L) do
     begin
       if Path[i]='.' then
       begin
         IDs[k-1]:=StrToInt(Copy(Path,j,i-j));
         j:=i+1;
         if i<>L then
         begin
           Inc(k);
           SetLength(IDs,k);
         end;
       end;
       Inc(i);
     end;
     Result:=LocateByPath(IDS)
   end
end;

function  TDBVirtualStringTree.FieldValue(const FieldName:string):variant;
begin
  Result:=FieldValue(FocusedNode,FieldName);
end;

function  TDBVirtualStringTree.FieldValue(Node:PVirtualNode; const FieldName:string):variant;
var
  i:integer;
  NodeData:PNodeData;
begin
  Result:=null;
  i:=DBOptions.FLookFields.IndexOf(FieldName);
  if (i>-1) or (DBOptions.FIDField=FieldName)
   or (DBOptions.FIDParentParam=FieldName)
  then
  begin
    NodeData:=GetNodeData(Node);
    if Assigned(NodeData) then
     if DBOptions.FIDField=FieldName then
      Result:=NodeData^.FIdRecord
     else
     if DBOptions.FIDParentParam=FieldName then
     begin
      NodeData:=GetNodeData(NodeData^.vNode.Parent);
      if Assigned(NodeData) and Assigned(NodeData^) then
        Result:=NodeData^.FIdRecord
      else
        Result:=DBOptions.FInitialParentValue;
     end
     else
      Result:=NodeData^.FValues[i];
  end;
end;

procedure TDBVirtualStringTree.KeyUp(var Key: Word; Shift: TShiftState);
var LO:TLocateOptions;
begin
  inherited;
  case Key of
    Ord('F'):
     if ssCtrl in Shift then
     begin
       FFindDlg.Execute
     end ;
    VK_F3:
     if (FFindDlg.FindText<>'') then
     begin
      if not (frMatchCase in FFindDlg.Options) then
        LO:=[loCaseInsensitive]
      else
        LO:=[];
      if not (frWholeWord in FFindDlg.Options) then
        LO:=LO+[loPartialKey];
        LocateNext(DBOptions.LookFields[0],FFindDlg.FindText,LO);
     end
     else
      FFindDlg.Execute;
    VK_DELETE:
    if (ssCtrl in Shift) and (dmkDelete in FDBOptions.ModifyKinds) then
     DeleteCurrentRecord;
    VK_INSERT:
     if (Shift=[]) and (dmkInsert in FDBOptions.ModifyKinds) then
      Insert;
  end;

end;

procedure TDBVirtualStringTree.DoOnDlgFind(Sender: TObject);
var LO:TLocateOptions;
begin
  if not (frMatchCase in FFindDlg.Options) then
    LO:=[loCaseInsensitive]
  else
    LO:=[];
  if not (frWholeWord in FFindDlg.Options) then
    LO:=LO+[loPartialKey];
  Self.Locate(DBOptions.LookFields[0],FFindDlg.FindText,LO);
  FFindDlg.CloseDialog
end;


function TDBVirtualStringTree.ChildsIDStr: string;
var
    arr:TIntArray;
    i:integer;
begin
  arr:=ChildsID; Result:='';
  for i:=Low(arr) to High(arr) do
   Result:= Result+IntToStr(arr[i])+',';
  if Result<>'' then
   SetLength( Result,Length(Result )-1);
end;

function TDBVirtualStringTree.HasCheckedNode: boolean;
{var
 i:integer;}
begin
{ Result := False;
 for i:=0 to Pred(FContenceList.Count) do
 with TVTNodeContence(FContenceList[i]) do
  if not (CheckState in [csUncheckedNormal,csUncheckedPressed])   then
   begin
     Result := True;
     Exit;
   end;}
//  Result:=FCheckedCount>0
 Result:=FCheckedNodes.Count>0
end;


function TDBVirtualStringTree.DoChecking(Node: PVirtualNode;
 var NewCheckState: TCheckState):boolean;
begin
  Result:= inherited DoChecking(Node, NewCheckState);
  vDoCheck:= Result or vDoCheck; 
  if Result then
  if NewCheckState=csCheckedNormal then
  begin
    if (Node.CheckState in [csUnCheckedNormal,csMixedNormal]) then
    begin
      if FCheckedNodes.IndexOf(Node)=-1 then
       FCheckedNodes.Add(Node);
    end;
  end
  else
  if (Node.CheckState=csCheckedNormal) and (NewCheckState in [csUnCheckedNormal,csMixedNormal]) then
  begin
    FCheckedNodes.Remove(Node)
  end;
end;



function TDBVirtualStringTree.GetCheckedCount: Integer;
begin
 Result:=FCheckedNodes.Count
end;

procedure TDBVirtualStringTree.WMLButtonUp(var Message: TWMLButtonUp);
begin
 try
  inherited;
  if vDoCheck then
   if Assigned(FDBOnEndChecking) then
    FDBOnEndChecking(Self);
 finally
  vDoCheck:=False;
 end;
end;

function TDBVirtualStringTree.GetCheckedNode(Index: integer): PVirtualNode;
begin
 Result:=PVirtualNode(FCheckedNodes[Index]);
end;

procedure TDBVirtualStringTree.Resize;
begin
  inherited;
end;

function TDBVirtualStringTree.DoGetImageIndex(Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var Index: Integer): TCustomImageList;
var
  Data :PNodeData;
begin
  if Kind<>ikOverlay then
  if Column<=0 then
  begin
    Data := GetNodeData(Node);
    if Assigned(Data) and Assigned(Data^) then
    if (Data^.ChildCount>0) then
     if vsExpanded in Node^.States then
        Index:= FImageIndexes.FExpandedImage
     else
        Index:= FImageIndexes.FCollapsedImage
    else
    if Data^.FAttemptExpanding and (dmkInsert in FDBOptions.ModifyKinds) then
     Index:= FImageIndexes.FExpandedImage
    else
     Index:= FImageIndexes.FChildImage;
  end;
  Result := inherited DoGetImageIndex(Node, Kind, Column, Ghosted, Index);
end;

{ TDBOptions }

constructor TDBOptions.Create(AOwner: TDBVirtualStringTree);
begin
 inherited Create ;
 FOwner:=AOwner;
 FInitialParentValue:=0;
 FLookFields :=TStringList.Create;
 FAutoCreateColumns:=False;
 FMaxAutoWidth:=200;
 FCanEdit     :=False;
 FDBModifyKinds:=[];
end;

destructor TDBOptions.Destroy;
begin
  FLookFields .Free;
//  FSource:=nil;
  inherited;
end;

function TDBOptions.IsValid: boolean;
var i:integer;
begin
 Result:= Assigned(FSource)
   and (FSource.IFieldExist(FIDField)) and (FSource.IParamExist(IDParentParam));
 if Result then
 for I := 0 to FLookFields.Count - 1 do
 begin
   Result:=FSource.IFieldExist(FLookFields[i]);
   if not Result then Exit;     
 end;
end;


procedure TDBOptions.SetSource(const Value: IDBRetrieveData);
var
  IC:IDBRetrieveData;
  DSAsCmp:TObject;
begin
  if Value=FSource then
   Exit;
  FOwner.Clear; 
  DSAsCmp:=nil;
  if Supports(FSource,GIDBRetrieveData,IC) then
   DSAsCmp:=IC.IGetInstance;
  if Assigned(DSAsCmp) and (DSAsCmp is TComponent) then
   TComponent(DSAsCmp).RemoveFreeNotification(FOwner);
  FSource := Value;
  DSAsCmp:=nil;
  if Supports(Value,GIDBRetrieveData,IC) then
   DSAsCmp:=IC.IGetInstance;
  if Assigned(DSAsCmp) and (DSAsCmp is TComponent) then
   TComponent(DSAsCmp).FreeNotification(FOwner);
  FCanEdit :=Supports(Source,GIDBModifyData,IC);
end;

procedure TDBOptions.SetLookFields(const Value: TStrings);
begin
  FLookFields.Assign( Value);
end;

{ TVTImageIndexes }

constructor TVTImageIndexes.Create(AOwner:TDBVirtualStringTree);
begin
   inherited Create;
   FExpandedImage  :=-1;
   FCollapsedImage :=-1;
   FChildImage     :=-1;
   FOwner:=AOwner;
   FDefaultCheckType :=ctNone
end;

end.

