=======================================================
            README FOR TDBVIRTUALSTRINGTREE
=======================================================

TDBVirtualStringTree is an ancestor of
VirtualStringTree. VirtualStringTree is at
www.lischke-online.de.

=======================================================
TDBVirtualStringTree features:
=======================================================

This is a tree, that loads data on opening a branch. It
is editable and contains filtering and search methods.
It supports drag and drop and you can use it in the
checkbox mode.

Description:

1. Additional properties of VirtualStringTree.
 
ImageIndexes:

  * ExpandedImage  - an index in the image list for the
    icon of an open node.
  * CollapsedImage - an index of the icon of a closed
    node with children.
  * ChildImage     - an index of the icon of a
    childless node.

DBOptions:

  * IDField - a name of the field with a node ID
  * IDParentParam - a name of the parameter denoting a
    parent in the query of getting all children of a
    node
  * LookFields: TStrings - a list of field names shown
    in the tree
  * HasChildField - a name of the field where
    information on current node children is kept
    (optional)
  * InitialParentValue - parent value for higher root
    nodes (equals 0 by default)
  * AutoCreateColumns - a flag of automatic creation of
    columns for LookFields
  * MaxAutoWidth - maximum width of automatically
    created columns
  * ModifyKinds - flags enabling tree editing

  * Source: IDBRetrieveData - a source of getting data
    for the tree. It should support this interface
    together with IDBModifyData in order to make the
    tree modify the source.

    Note:

    Examples of such sources based on FIBPlus see in
    the unit FIBVTreeCmps.pas of the package
    FIBVTreeComponents.dpk

2. Methods.

* procedure LoadTree;
 
This is initial loading of primary nodes. It checks
Source, clears the tree and calls the following methods
of Source:

 IClose;
 ISetParamValue(IDParentParam,ParamValue);
 IOpen;

where the parameter is DBOptions.InitialParentValue.
Then it gets the result by other Source methods and
fills in the tree.

* function LoadChild(ParentNode: PVirtualNode): integer;

It loads the node children set in the input parameter.
It is called automatically on opening a node if it is
not opened yet.

* function RecordId: integer;

returns the ID of the current node

* function ParentId: integer;

returns the ParentID of the current node

* procedure ExpandParents(Node: PVirtualNode);

opens all parents of the set node

* function FindNode(aRecordId: integer): PVirtualNode; overload;

finds a node by its ID. (nothing happens with control
and nobody focuses on the found node.

* function FindNode(StartNode: PVirtualNode;
  const Fields: string; FilterValues: variant;
  LocateOptions: TLocateOptions): PVirtualNode; overload;

finds a node by some condition. Acts like the previous
one. At present does not work by many fields yet.

* function LocateById(aRecordId: integer): boolean;

if it finds a node, it locates there

* function Locate(const Fields: string; FilterValues:
  variant; LocateOptions: TLocateOptions): boolean;

it finds a node not by the ID field. If it finds a
node, it locates there

* function LocateNext(const Fields: string;
  FilterValues: variant; LocateOptions: TLocateOptions): boolean;

it finds a node starting from the current node downwards

* function LocateByPath(Path: array of integer): boolean; overload;
* function LocateByPath(const Path: string): boolean; overload;

finds a node by a path to it and locates there. in the
second case the path is transferred as 0.1.2.13.3

* function CacheEdit(aRecordId: integer; const Fields:
  array of string; const Values: array of variant): boolean;
* function CacheInsert(aParentId, aRecordId: integer;
  const Fields: array of string; const Values: array of
  variant): boolean;
* function CacheDelete(aRecordId: integer): boolean;

Modifications of the current node without sending the
changes to the database

* function CurrentHasChild: boolean;

checks whether the current node has children (even if
they are not loaded yet)

* function DeleteCurrentRecord: boolean;

deletes the current node (will delete children from the
control/ to delete them from the database you will have
to do it manually or make an exception by a trigger)

* procedure Insert;

inserts a node

* function IsVisibleRecord (aRecordId: integer): boolean;

gets to know if we see a node with the set ID

* function NodeId (Node: PVirtualNode): integer;

shows the ID of the set node

* function HasCheckedNode: boolean;

checks whether there are checked nodes


3. Other properties

* property CheckedCount: Integer

shows how many nodes have been checked

* property CheckedNode[Index: integer]: PVirtualNode

shows a reference to the checked node with the set index


4. Events.

* DBOnChangeCurrentRecord: procedure (Sender:
  TDBVirtualStringTree; RecordId:integer)

it appears on moving the cursor from node to node.
RecordId is an ID of the current node

 DBBeforeDeleteRecord - before deletion
 DBAfterDeleteRecord  - after deletion
 DBBeforeEditRecord   - before editing
 DBAfterEditRecord    - after editing

* DBOnFilterRecord: procedure (Sender:
  TDBVirtualStringTree; RecordId: integer;
  var Accept: boolean)

it activates for each node just after the tree becomes
filtered.

Working with the Accept flag we either make a node
visible or not

* DBBeforeFiltered: procedure (Sender:
  TDBVirtualStringTree; DoFiltered: boolean) of object;

It appears before making the tree filtered or not
filtered. You can do there some preparations.

* DBAfterFiltered

it appears after making the tree filtered (in the demo
example you can see it focused on the first node that
completely satisfies filtering condition)

* DBOnFindNode is called during execution of FindNode.
It is used to inform the search whether it is necessary
to open the current node or there is no required child
in the node children.

* DBBeforeLocate is used before Locate to call actions
preparing for it.

* DBAfterLocate is used after Locate.

=======================================================

See also our demo illustrating other features and
abilities.
