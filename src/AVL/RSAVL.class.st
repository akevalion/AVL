"
AVL https://en.wikipedia.org/wiki/AVL_tree
"
Class {
	#name : #RSAVL,
	#superclass : #Collection,
	#instVars : [
		'root'
	],
	#category : #AVL
}

{ #category : #adding }
RSAVL >> add: newObject [ 
	root isNilNode
		ifTrue: [ root := RSAVLNode with: newObject ]
		ifFalse: [ | path |
			path := OrderedCollection with: nil -> root.
			root add: newObject path: path.
			self checkPath: path ].
	^ newObject
]

{ #category : #accessing }
RSAVL >> allChildren [
	| list |
	list := OrderedCollection new.
	self root withAllChildren: list.
	^ list
]

{ #category : #private }
RSAVL >> balance: index path: aCollection [ 
	| x y z a b c |
	z := aCollection at: index.
	y := aCollection at: index + 1.
	x := aCollection at: index + 2.
	c := z value.
	b := y value.
	a := x value.
	(y key and: [ x key ]) ifTrue: [ 
		^ self rrrotationZ: c y: b x: a ].
	(y key not and: [ x key not ]) ifTrue: [ 
		^ self llrotationZ: c y: b x: a ].
	(y key not and: [ x key ]) ifTrue: [ 
		^ self lrrotationZ: c y: b x: a ].
	"(y key and: [ x key not ])"
	^ self rlrotationZ: c y: b x: a.
	"self notYetImplemented."
]

{ #category : #private }
RSAVL >> balanceZ: z y: y x: x [
	| a b c |
	c := z value.
	b := y value.
	a := x value.
	(y key and: [ x key ]) ifTrue: [ 
		^ self rrrotationZ: c y: b x: a ].
	(y key not and: [ x key not ]) ifTrue: [ 
		^ self llrotationZ: c y: b x: a ].
	(y key not and: [ x key ]) ifTrue: [ 
		^ self lrrotationZ: c y: b x: a ].
	"(y key and: [ x key not ])"
	^ self rlrotationZ: c y: b x: a.
	"self notYetImplemented."
]

{ #category : #private }
RSAVL >> checkPath: aCollection [ 
	aCollection size < 3 ifTrue: [ ^ self ].
	(1 to: aCollection size - 2) reverseDo: [ :index |
		| assoc |
		assoc := aCollection at: index.
		assoc value isBalanced ifFalse: [ | z y x |
			z := aCollection at: index.
			y := aCollection at: index + 1.
			x := aCollection at: index + 2.
			^ self balanceZ: z y: y x: x ] ]
]

{ #category : #private }
RSAVL >> checkRemovingPath: path [
	path reverseDo: [ :node | 
		node isBalanced ifFalse: [ | z y x |
			z := node.
			y := z largerNode.
			x := y value largerNode.
			self balanceZ: node y: y x: x ] ].
]

{ #category : #'as yet unclassified' }
RSAVL >> createCanvas [
	| canvas children |
	canvas := RSCanvas new.
	children := self allChildren collect: [ :child | self createNode: child ].
	canvas addAll: children.
	RSLineBuilder line
		canvas: canvas;
		withBorderAttachPoint;
		markerEnd: (RSShapeFactory arrow size: 10);
		shapes: children;
		connectToAll: [ :child | child children ].
	RSTreeLayout on: children.
	canvas @ RSCanvasController simple.
	^ canvas
]

{ #category : #'as yet unclassified' }
RSAVL >> createNode: node [ 
	| label w h back |
	label := RSLabel new 
		text: node contents asString;
		color: 'black';
		yourself.
	w := label width.
	h := label height.
	back :=RSEllipse new
		size: (w max: h)+5;
		border: (RSBorder new color: 'black');
		color: (node isBalanced
			ifTrue: ['green']
			ifFalse: ['red']);
		yourself.
		
	^ { back. label } asShape
		model: node;
		padding: 7;
		draggable;
		yourself.
]

{ #category : #enumerating }
RSAVL >> do: aBlock [ 
	root do: aBlock
]

{ #category : #public }
RSAVL >> height [
	^ root height
]

{ #category : #testing }
RSAVL >> includes: anObject [
	anObject ifNil: [ ^ nil ].
	^ (self search: anObject) notNil
]

{ #category : #initialization }
RSAVL >> initialize [
	super initialize.
	root := RSAVLNilNode new.
]

{ #category : #'as yet unclassified' }
RSAVL >> inspectorCanvas [
	<inspectorPresentationOrder: 90 title: 'AVL'>
	^ SpRoassal3InspectorPresenter new
		canvas: self createCanvas;
		yourself 
]

{ #category : #testing }
RSAVL >> isBalanced [
	^ root isBalanced
]

{ #category : #testing }
RSAVL >> isTotalBalanced [
	^ root isTotalBalanced
]

{ #category : #private }
RSAVL >> llrotationZ: z y: y x: x [ 
	| a3 a4 new |
	a3 := y right.
	a4 := z right.
	
	new := RSAVLNode with: z contents.
	new left: a3; right: a4.
	z left: x; contents: y contents; right: new.
	
]

{ #category : #private }
RSAVL >> lrrotationZ: z y: y x: x [ 
	| a1 a2 a3 new |
	a1 := y left.
	a2 := x left.
	a3 := x right.
	new := RSAVLNode with: y contents.
	new left: a1; right: a2.
	y contents: x contents; left: new; right: a3.
	
	self llrotationZ: z y: y x: new
]

{ #category : #removing }
RSAVL >> remove: oldObject ifAbsent: anExceptionBlock [
	| toRemove path |
	path := OrderedCollection new.
	toRemove := root remove: oldObject path: path.
	toRemove ifNil: [ ^ anExceptionBlock value ].
	toRemove == root ifTrue: [ 
		root := root successor: path.
		root ifNil: [ root := RSAVLNilNode new ] ].
	self checkRemovingPath: path.
	^ toRemove contents
]

{ #category : #private }
RSAVL >> rlrotationZ: z y: y x: x [ 
	| a1 a2 a3 a4 new |
	a1 := z left.
	a2 := x left.
	a3 := x right.
	a4 := y right.
	new := RSAVLNode with: y contents.
	new left: a3; right: a4.
	y contents: x contents; left: a2; right: new.
	self rrrotationZ: z y: y x: new
]

{ #category : #accessing }
RSAVL >> root [
	^ root
]

{ #category : #private }
RSAVL >> rrrotationZ: z y: y x: x [
	"right right rotation"
	| a1 a2 new |
	a1 := z left.
	a2 := y left.
	
	new := RSAVLNode with: z contents.
	new left: a1; right: a2.
	z left: new; right: x; contents: y contents
	
]

{ #category : #search }
RSAVL >> search: anInteger [ 
	^ root search: anInteger
]
