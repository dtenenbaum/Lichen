package {
	import com.adobe.serialization.json.JSON;
	
	import flare.animate.Transitioner;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.ArrowType;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.legend.Legend;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.ForceDirectedLayout; 
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import org.systemsbiology.visualization.GoogleVisAPISprite;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.MultiEdgeRenderer;
	import org.systemsbiology.visualization.bionetwork.layout.*;
	import org.systemsbiology.visualization.control.ClickDragControl;
	import org.systemsbiology.visualization.data.DataView;
	//This class is primarily responsible for configuring the network from the data in Google data tables and options passed in from the view.
	//for now, updates cause the sprite to be redrawn completely. The data update is sort of smart (appends to data table rather than rewriting).
	//the network object persists the data
	public class bionetwork extends GoogleVisAPISprite
	{	
		private var data:Data = new Data();
		private var network:Network = new Network(data);		
		//config variables
		private var options:Object; 
		private var centerNode:int;
		private var layoutTable:DataView;
		private var nodeDataTable:DataView;
		private var tempTable:DataView;
		private var layoutType:String;
		private var dataTable:DataView;
		private var attributesTable:DataView;
		private var visWidth:int = stage.stageWidth;
		private var visHeight:int = stage.stageHeight;
		private var vis:Visualization;
		private var _fmt:TextFormat = new TextFormat("Verdana", 14);
		private var _detail:TextSprite;
		private var maxLabelWidth:Number;
		private var maxLabelHeight:Number;
		private var _trans:Object = {};
		private var _nodes:Array;
		private var regularColor:uint = 0xff0000ff;
		private var rootColor:uint = 0xffff0000;
		private var frameSize:int=40;
		private var lastRoot:NodeSprite = null;
		private var info1:TextSprite;
		private var info2:TextSprite;
		private var legend:Legend;
		//font
        // We must embed a font so that we can rotate text and do other special effects
           [Embed(systemFont='Helvetica', 
            fontName='myHelveticaFont', 
            mimeType='application/x-font'
        )] 
        // You do not use this variable directly. It exists so that 
        // the compiler will link in the font.
        private var _font1:Class;
        private var _fontHeight:int = 14;                
        private var  _labelTextFormat : TextFormat = new TextFormat('myHelveticaFont',14);

	//for basic network	
	public function bionetwork() {
		ExternalInterface.addCallback("redraw", redraw);
		super();	
	}
		
	//for sprouting
	public function redraw(dataJSON:String, optionsJSON:String) :void {			
//			var newDataTable:DataView;
//			trace("REDRAW");
//			trace(this.map);
//			trace(this.centerNode);
//			trace(dataJSON);
//			trace(optionsJSON);
//			this.datat = JSON.decode(dataJSON);
//			this.options = JSON.decode(optionsJSON);	
////			this.centerNode=this.options['center'];
//			this.dataFormat=this.options['data_format'];
//			if (this.dataFormat=='static'){
//				trace("static");
//				dataTable = new DataView(JSON.encode(this.datat), "False");
//			}
//			else{
//				trace("google");
//				dataTable = new DataView(JSON.encode(this.datat), "True");
//			}
//			trace("attribute encoding");
//			//need to loop through datatable to see what already exists, currently writes over data
//			this.attributes = new DataView(JSON.encode(this.options['attributes']), "False");
//            this.resizeStage(visindex, dataTable, options);
//            drawAfterResize(dataTable,{},{});         
		}
			
		//de-serialize
	private function importFromJSON(dataJSON:String, optionsJSON:String) :void {						
		this.options = JSON.decode(optionsJSON);
		this.layoutType = this.options['layout'];	
		this.centerNode=this.options['center'];	
		
		//data tables
		//import data JSON
		if (this.dataTable!=null){
			//loop through datatable and add rows; does the table need to be updated?
			this.tempTable = new DataView(dataJSON, "");
			this.constructGraph(this.tempTable);
		}
		else {
			this.dataTable = new DataView(dataJSON, "");
		}
		
		if (this.options['layout_data']){				
			this.layoutTable = new DataView(JSON.encode(this.options['layout_data']),"");
		}
		else{
			this.layoutTable=null;
		}
		
		if (this.options['node_data']){				
			this.nodeDataTable = new DataView(JSON.encode(this.options['node_data']),"");
		}
		else{
			this.nodeDataTable=null;
		}
		
		
		if (this.options['attributes']){
			//already exist
			if (this.attributesTable!=null){
				
			}
			else {
				this.attributesTable = new DataView(JSON.encode(this.options['attributes']), "");
			}	
		}
		else{
			this.attributesTable=null;
		}
        this.resizeStage(visindex, dataTable, options);
        //drawAfterResize(this.dataTable, this.attributes, this.layout);         
	}

	//redraw without loading new data
	private function updateLayoutParams():void{
		
	}
	
//	public function update_data(testString:String):void {
//		trace("update_data");
//		ExternalInterface.call("update_data");
//		showText(info1,"update",0xff0000);
//	}

		// draw!
	public override function draw(dataJSON:String, optionsJSON:String) :void {            			
		this.importFromJSON(dataJSON, optionsJSON);
		this.resizeStage(visindex, this.dataTable, options);
		this.constructGraph(this.dataTable);

		//trace("LAYOUT DATA");
		//layout from layoutTable
		if (this.layoutTable!=null){
			this.importLayout(this.layoutTable);
		}		
		
		if (this.nodeDataTable!=null){
			this.importTimeCourseData(this.nodeDataTable);
		}
			
		this.setLayout();
		
		if (options['clickdrag']!=false){
			var cdc:ClickDragControl = new ClickDragControl(NodeSprite,1,true);
			this.network.controls.add(cdc);
		}
		this.setLabels();
        this.network.x = 0;
        this.network.y = 0;
		
		if (this.options['legend']!='false'){
			this.createLegend();
		}
		addChild(this.network);
		//trace("update network sprite");
		this.network.update();
}	
	private function createLegend():void {
		var legend_fmt:TextFormat = new TextFormat("Verdana",14);
		legend = Legend.fromValues(null, [
				{color: 0x3366CC, size: 0.75, label: "HPRD"},
				{color: 0x339900, size: 0.75, label: "MINT"},
				{color: 0xA2627A, size: 0.75, label: "IntAct"},
				{color: 0xFF6600, size: 0.75, label: "MIPS"},
				{color: 0xFF0000, size: 0.75, label: "BioGRID"}
			]);
			legend.labelTextFormat = legend_fmt;
			//legend.labelTextMode = TextSprite.EMBED;
			legend.update();
			addChild(legend);
	}

	//DATA IMPORT FUNCTIONS

	private function constructGraph(dataTable:DataView):void {
		
		var fmt:TextFormat = new TextFormat();
		fmt.color = 0x000000;
			fmt.size = 14;
			fmt.bold = true;
		
		var ttc:TooltipControl = new TooltipControl(NodeSprite);
		(ttc.tooltip as TextSprite).textFormat = fmt;
			
			ttc.addEventListener(TooltipEvent.SHOW,function(evt:TooltipEvent):void {
				trace("the node you moused over is: " + evt.node.data.name);
				(ttc.tooltip as TextSprite).textField.text = evt.node.data.name;//"HERE IS YOUR TOOLTIP";//evt.node.name;
				(ttc.tooltip as TextSprite).render();
			});
			
			this.network.controls.add(ttc); 
	
	
/*
		var etc:TooltipControl = new TooltipControl(NodeSprite);
		(etc.tooltip as TextSprite).textFormat = fmt;
			
			etc.addEventListener(TooltipEvent.SHOW,function(evt:TooltipEvent):void {
				trace("the edge you moused over is: " + evt.edge.data.name);
				(etc.tooltip as TextSprite).textField.text = evt.node.data.name;
				(etc.tooltip as TextSprite).render();
			});
			
			this.network.controls.add(etc);
*/
		
		
		//trace("construct graph");
		var interactor_name1:String;
		var interactor_value1:String;
		var interactor_name2:String;
		var interactor_value2:String;
		var interactor1:NodeSprite;
		var interactor2:NodeSprite;
		var ixnsources:Array;
		var edge:EdgeSprite;
		var directed:Boolean=false;	
		var orphan:Boolean=false;
		for (var i:Number = 0; i<dataTable.getNumberOfRows(); i++) {
			//trace("howdy");
			interactor_name1=dataTable.getFormattedValue(i,1);
			//trace("formatted_name1" + interactor_name1);
			interactor_value1=dataTable.getValue(i,1);
			//trace("value1" + interactor_value1);
			interactor_name2=dataTable.getFormattedValue(i,2);
			interactor_value2=dataTable.getValue(i,2);
			orphan = (interactor_value2 == null || interactor_value2 == '');
			
			if (interactor_value1==interactor_value2){
				continue;
			}
				for(var j:Number=3; j<dataTable.getNumberOfColumns(); j++){
					var cellValue:String = dataTable.getValue(i,j);
					//trace("Cell" + cellValue);
					var columnName:String = dataTable.getColumnLabel(j);
					if (columnName=='sources'){
						trace("SOURCES");
						if (cellValue != null) {
							trace("sources is: " + cellValue);
							ixnsources=cellValue.split(", ");
						}
					}
					else if (columnName=='directed'){
						directed = Boolean(cellValue=='true');
					}
			}

				//begin dan
				/*
				interactor1=this.network.addNodeIfNotExist(interactor_name1);
				if (interactor_name2) {
					interactor2=this.network.addNodeIfNotExist(interactor_name2);
				}
				*/
				//end dan
				
				//begin ryan
							//this section replace network.addnodeifnotexsistant calls
			//i needed to be able to do things to nodes once on creation for selection stuff
			//
			//
			
			interactor_name1 = interactor_name1 ? interactor_name1 : interactor_value1;
			interactor_name2 = interactor_name2 ? interactor_name2 : interactor_value2;
			var interactors : Array = new Array();
			for each(var name : * in [interactor_name1,interactor_name2])
			{
				if (!name) continue;	
				if (!network.checkNode(name)){
					trace("create");
					var interactor : NodeSprite = network.addNode({name:name});
					//things that need to be done to each node once
					interactor.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
					_appendSelectionInfo(interactor,{node:name});					
					interactors.push(interactor);
				}
				else{
					interactors.push(network.findNodeByName(name));
				}
			}
						interactor1 = interactors[0];
			interactor2 = interactors[1];
				//end ryan

			
			
			if (!orphan) {
				//trace("adding edge");
				edge=this.network.addEdgeIfNotExist(interactor1, interactor2, directed);
				_addSelectionCapabilities(edge,interactor1,interactor2,i);
				//edge.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverEdge);
			} else {
				_addSelectionCapabilitiesForNode(interactor1, i, 1);
			}		

			//loop through ixn sources
			if ((ixnsources) && (!orphan)){
				for (var k:Number=0; k<ixnsources.length; k++){
					this.network.addEdgeSource(edge, ixnsources[k]);
				}
			}
			
		this.network.data.nodes.visit(addSelectListener);
		this.network.data.edges.visit(addSelectListener);
		}
	}
	
	private function onMouseOverNode(event:MouseEvent):void {
		trace("over a node");
		//event.target
	}
	
	private function onMouseOverEdge(event:MouseEvent):void {
		trace("over an edge");
	}

    private function importLayout(layoutTable:DataView):void {
    	var layoutValues:Array = new Array();
    	var layoutAttributeValue:String;
    	var params:Object = {};
   		for (var i:Number = 0; i<layoutTable.getNumberOfRows();i++) {
			//first column name
			var interactor_name:String = layoutTable.getValue(i,0);
			//rest of columns layout attributes (first two are x,y)
			for (var j:Number = 1; j < layoutTable.getNumberOfColumns(); j++){
				var columnName:String = layoutTable.getColumnLabel(j);
				layoutAttributeValue = layoutTable.getValue(i,j);
				//branch to set main nodesprite properties
				if (columnName=='shape'){
					this.network.setNodeShape(interactor_name, layoutAttributeValue);
				}
				else if (columnName == 'color'){
					this.network.setNodeColor(interactor_name, layoutAttributeValue);
				}
				else if (columnName == 'size'){
					this.network.setNodeSize(interactor_name, int(layoutAttributeValue));
				}
				else {
					params[columnName]=int(layoutAttributeValue);
					this.network.updateNodeParams(interactor_name,params);
				}
			}	
		}
    }
	
	private function importTimeCourseData(nodeDataTable:DataView):void{
		//trace("IMPORT_TIME_COURSE_DATA");
		var data = {};
		for (var i:Number = 0; i<nodeDataTable.getNumberOfRows();i++) {
			//first column name
			var interactor_name:String = nodeDataTable.getValue(i,0);
			for (var j:Number = 1; j < nodeDataTable.getNumberOfColumns(); j++){
				trace(nodeDataTable.getColumnLabel(j));
				data[nodeDataTable.getColumnLabel(j)]=nodeDataTable.getValue(i,j);
			}
			this.network.setTimecourseData(interactor_name, data);
			data={}
		}
	}
	
	//Currently written specifically for GO
	private function importAnnotations(annotationTable:DataView):void{
		var columnName:String;
		var attributeValue:String;
		if (annotationTable!=null){
			for (var i:Number = 0; i<annotationTable.getNumberOfRows(); i++) {
				var interactor_name:String = annotationTable.getFormattedValue(i,0);
				var annotation_id:String = annotationTable.getValue(i,1);
				var annotation_name:String = annotationTable.getValue(i,2);
				this.network.addAnnotation(interactor_name, annotation_name);
			}
		}
	}
	
	
	private function _addSelectionCapabilitiesForNode(node:NodeSprite, i:int, col:int): void {
		node.addEventListener(MouseEvent.CLICK,this._selectionHandeler);

		node.addEventListener(MouseEvent.CLICK,this.onLocalNodeSelect);
		
		_appendSelectionInfo(node,{row:i,col:col});
		
	}
	
	private function _addSelectionCapabilities(edge:EdgeSprite, interactor1 :NodeSprite, interactor2:NodeSprite, i:int) : void
	{
		_addSelectionCapabilitiesForNode(interactor1, i, 1);
		_addSelectionCapabilitiesForNode(interactor2, i, 2);

		edge.addEventListener(MouseEvent.CLICK,this._selectionHandeler);

		edge.addEventListener(MouseEvent.CLICK,this.onLocalNodeSelect);



		_appendSelectionInfo(edge,{row:i});
		
	}
	
	private function onLocalNodeSelect(event:MouseEvent):void {
		trace(" a node was selected " );
		var node:NodeSprite = event.target as NodeSprite;
		
		//this is where you would do something when the user clicks on a node
		
		
		this.network.toggleNodeColor(node.data.name);
		
	}
	
	private function _appendSelectionInfo(ds:DataSprite,selection : Object) : void
	{
		if(ds.props.hasOwnProperty("selection"))
		{
			ds.props.selection.push(selection);
		}
		else
		{
			ds.props.selection = [selection];
		}
	}
	
	private function addNodeSelectionInfo (ns:NodeSprite):Boolean {
		_appendSelectionInfo(ns,{node:ns.name});
		return true;
		}
	
	private function addSelectListener (ds:DataSprite):Boolean {
		 
		ds.addEventListener(MouseEvent.CLICK,this._selectionHandeler); 
		return true;
		}

	private function setLayout():void{
		//set defaults
		this.network.data.nodes.setProperties({fillColor:0xff0055cc, fillAlpha: 0.2, lineWidth:0.5, visible:true});     
		//this.network.data.nodes.setProperties({renderer: CircularHeatmapRenderer.instance});
		//var lay:CircleLayout =  new CircleLayout(null, null, false);
		//var lay:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
		if (this.options['layout']=="ForceDirected"){
			this.network.data.nodes.setProperties({x:315, y:315});     	
	    	this.network.continuousUpdates = false;
	    	//force directed layout

			var fdlay:ForceDirectedLayout = new ForceDirectedLayout(true,120);
	    	fdlay.simulation.dragForce.drag=1;
	    	fdlay.simulation.nbodyForce.gravitation=-128;  
	        fdlay.defaultParticleMass= 6;
	        fdlay.defaultSpringLength=100;
	        fdlay.defaultSpringTension= 0.1;
	        this.network.operators.add(fdlay);	
		}
		else if (this.options['layout']=="GoogleDataTableDriven"){
			var gddlay:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
			this.network.operators.add(gddlay);
			
			//shape: flare.util.Shapes.SQUARE,
		}
		//default circular layout
		else {
			var clay:CircleLayout =  new CircleLayout(null, null, false);
			this.network.operators.add(clay);
		}
		
		if (this.options['edgeRenderer']=='multiedge'){
			trace("+++USER has selected multi edge renderer");
			this.network.data.edges.setProperties({
				lineWidth: 0.5,
				lineAlpha: 1,
				arrowType: "TRIANGLE",
				lineColor: 0xff0000bb,
				mouseEnabled: true,
				visible:true,
				renderer: MultiEdgeRenderer.instance
			});
		}
		
		this.network.data.edges.setProperties({
			arrowType: ArrowType.TRIANGLE,
			lineAlpha: 1,
			arrowWidth: 15,
			arrowHeight: 15
			}, null, function(e:EdgeSprite):Boolean{return e.directed==true;}
		);
			
			
		this.network.data.nodes.setProperties({
			fillAlpha: 0.5
			});
		
	}

	private function setLabels():void {
			var labeller:Labeler = new Labeler(function(d:DataSprite):String {
		return String(d.data.name);
		});
		labeller.yOffset=15;
		labeller.xOffset=5;
		this.network.operators.add(labeller);
	}
	private function getTransitioner(taskname:String,duration:Number=1,easing:Function=null,optimize: Boolean = false):Transitioner {
                
		if (_trans[taskname] != null) {    //here we could also check for running but disposing never harms ...        
	        _trans[taskname].stop();
	        _trans[taskname].dispose();
	    }               
		    _trans[taskname] = new Transitioner(duration,easing,optimize);
		    return _trans[taskname];
		}

		// calculates the size of the visualization from the data and options
		// then resizes the container element via javascript
		
	private function resizeStage(visindex:String, dataTable:DataView, options:Object) :void {
     	//calculate width and height ...			
     	var width:int = 630;
     	var height:int = 630;         	
		//resize containing div to resize the flash movie (which is set to height/width 100%)
        ExternalInterface.call("function(){isbSWFvisualizations."+this.visindex+".containerElement.style.height = "+ height +" + \"px\"; $(\""+ visindex +"\").style.width = "+ width +" + \"px\";  }");
        ExternalInterface.call("function(){isbSWFvisualizations."+this.visindex+".containerElement.style.scroll = yes;  }");
		this.network.bounds = new Rectangle(0, 0, width, height);
		// resizeHandler(event) is now called!
	}
		
	private function updateRoot(n:NodeSprite):void {	
		vis.data.root = n; // needed for RootInCenterCircleLayout 
		var t1:Transitioner = getTransitioner("rootUpdate",2);
		setNodeColor(lastRoot,t1,regularColor);
		setNodeColor(n,t1,rootColor);
		lastRoot = n;	
		vis.update(t1).play();
	}
		
	private function setNodeColor(ns:NodeSprite,t:Transitioner,color:int):void {
		if (ns != null) {
			var rs:RectSprite = ns.getChildAt(0) as RectSprite;
			t.$(rs).fillColor = color; 
			t.$(rs).lineColor = color; 
		}	
	}
		
	//methods for ClickDragControl
	private function onComplete(evt:Event):void {
			var li:LoaderInfo = evt.target as LoaderInfo;
			var ns:NodeSprite = li.loader.parent as NodeSprite;	
			li.loader.x = -li.width / 2;
			li.loader.y = -li.height / 2;
			var t:Transitioner = new Transitioner(4);
			t.$(ns).alpha = 1;
			var es:EdgeSprite;
			ns.visitEdges(function(es:EdgeSprite):void {
				if ((es.target != ns && es.target.parent.alpha > 0) || (es.source != ns && es.source.parent.alpha > 0)) {
					t.$(es).alpha = 1;
				}
			});
			
			t.play();
		}
		
		private function onSingleClick(evt:SelectionEvent):void {
		ExternalInterface.call("test");
//			showText(info1,"single click on node " + evt.node.data.name);
			ExternalInterface.call("test");
			trace("click");
		}

		private function onSingleClickDeselect(evt:SelectionEvent):void {
//			if (info1.alpha > 0) //deselect info only if text is shown at the moment
//			showText(info1,"single click deselect",0xff0000);
		}
		
//		private function onDoubleClick(evt:SelectionEvent):void {
//			showText(info2,"double click on node " + evt.node.data.name);
//			ExternalInterface.call("sprout", evt.node.data.name);
//			
//			trace("sprouted on " + evt.node.data.name);
//		}
//		private function onDoubleClickDeselect(evt:SelectionEvent):void {
////			if (info2.alpha > 0)
////			showText(info2,"double click deselect",0xff0000);
//		}
		
//		private function showText(info:TextSprite,text:String,co:uint=0x000000):void {
//			var t1:Transitioner = getTransitioner(info.name + "-in",1); //info.name to distinquish info1 and info2 
//			var t2:Transitioner = getTransitioner(info.name + "-out",1);
//			t1.$(info).alpha = 1;
//			t2.$(info).alpha = 0;
//			info.text = text;
//			info.color = co;
//			new Sequence(t1,new Pause(2),t2).play();
//		}
		
		// called when movie is left-clicked on (aka "activated")
		private function activateHandler(event:Event):void {
            
        }

		// called when the movie's area is resized (by browser or javascript manipulation)
        private function resizeHandler(event:Event):void {
         
            //this.drawAfterResize(dataTable = new DataView("{}","False"));
           // this.drawAfterResize({},{},{});
        }		
	}
}
