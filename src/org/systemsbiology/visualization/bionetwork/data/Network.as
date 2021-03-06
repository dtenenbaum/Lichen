package org.systemsbiology.visualization.bionetwork.data
{
	import flare.query.methods.*;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
		
	public class Network extends Visualization
	{
		private var changed:Boolean = false;	
		public function Network(data:Data)
		{	
			super(data);
			this.data.addGroup("Annotations");
		}
		
		//function from data class tweaked to make it easier to add nodes with type
		public function addNode(n:Object, groupName:String=null):NodeSprite
		{
			var node:NodeSprite=this.data.addNode(n);
			if (groupName!=null){
				this.data.group(groupName).add(node);
			}
			return node;
		}
		
		//wrapper function
		public function addEdge(source:NodeSprite, target:NodeSprite, directed:Object = false):EdgeSprite
		{
			return this.data.addEdgeFor(source, target, directed);
		}
		
		//add edge if doesn't already exist; if exist returns node
		public function addEdgeIfNotExist(source:NodeSprite, target:NodeSprite, directed:Object = false):EdgeSprite
		{
			if (!checkEdge(source.name, target.name,directed)){
				return this.data.addEdgeFor(source, target, directed);
			}
			else {
				return this.findEdgeByNodes(source.name,target.name);
			}
		}
		
		//tie a source to an edge
		public function addEdgeSource(edge:EdgeSprite, source:String){
			if (edge.props.ixnsources==null){
				edge.props.ixnsources = [source];
			}
			else{
				edge.props.ixnsources.push(source); 
			}
		}
		
		public function getEdgeSource(edge:EdgeSprite):Array
		{
			return edge.props.ixsources;
		}
		
		public function checkNode(name:String):Boolean
		{
			trace("check node: " + name);
			var nodes:Array = [];
			nodes = select("data")
				.eval(this.data.nodes);
			var names:Array = nodes.map(extractNames);
			trace("there?");
			trace(-1!=names.indexOf(name));
			return -1!=names.indexOf(name);
		}
		
		//for none built-in param
		public function updateNodeParams(name:String, params:Object):void{
			trace("updateNodeParams");
			var node:NodeSprite=this.findNodeByName(name);
			for(var param in params){
				trace("PARAMS " + param);
				this.data.nodes.setProperty("props."+param, params[param], null, function(n:NodeSprite):Boolean{return n.data.name==name;});				
			}
		}	
		
		//set time course data
		public function setTimecourseData(name:String, timecourse_data:Object) :void{
			trace("setTimecourseData");
			trace(name);
			this.data.nodes.setProperty("props.timecourse_data", timecourse_data, null, function(n:NodeSprite):Boolean{return n.data.name==name;});			
		}
		
		//need to work in backword direction too or just accept edge
		public function setEdgeColor(source:NodeSprite, target:NodeSprite, color:String){
			
		}
		
		public function setNodeColor(name:String, color:String):void{
			trace("setNodeColor");
			this.data.nodes.setProperty("fillColor", color, null, function(n:NodeSprite):Boolean{return n.data.name==name;}); 
		}
		
		public function toggleNodeColor(name:String):void{
			trace("toggleNodeColor");

			var originalColor:Number = 0x7F0055CC;
			var selectedColor:Number = 0xff0000ff;

			this.data.nodes.visit(function(ns:NodeSprite):void {
				ns.fillColor = originalColor;
			});


			this.data.nodes.visit(function(ns:NodeSprite):void {
				if (ns.data.name == name) {
					trace("node color before change:" + ns.fillColor);
					var color:Number = (ns.fillColor == originalColor) ? selectedColor : originalColor;
					ns.fillColor = color;
				}
			});
		}
			

		
		public function setNodeShape(name:String, shape:String):void{
			trace("setNodeShape");
			trace(shape);
			this.data.nodes.setProperty("shape", Shapes[shape], null,  function(n:NodeSprite):Boolean{return n.data.name==name;});
//			this.data.nodes.setProperty("size", 10); 
		}		
		
		public function setNodeSize(name:String, size:Number):void{
			trace("setNodeSize");
			this.data.nodes.setProperty("size", size, null, function(n:NodeSprite):Boolean{return n.data.name==name;}); 
		}	
		
		public function checkEdge(name1:String, name2:String, directed:Object = null):Boolean 
		{
			trace("check edge");
			var targets:Array = [];
			var sources:Array = [];	
			targets=getTargets();
			sources==getSources();	
			for (var i:Number = 0; i<targets.length; i++){
				var source:NodeSprite = targets[i];
				var target:NodeSprite = targets[i];
				if (source==null || target==null){
					continue;
				}	
				if (eq(source.data.name,name1) && (eq(target.data.name,name2))){
					return true;
				}
				else if (eq(source.name,name1) && (eq(source.name,name2))){
					return true;
				} 
			}
			return false;
		}
//		
		public function findNodeByName(name:String):NodeSprite
		{
			trace("find node: " + name);
			var nodes:Array = [];
			nodes = select("data")
				.eval(this.data.nodes);
			var names:Array = nodes.map(extractNames);
			var node_index:int=names.indexOf(name);
			if (neq(node_index, -1)){
				return this.data.nodes[node_index];
			}
				return null;
		}
		
		public function findEdgeByNodes(source_name:String, target_name:String):EdgeSprite{
			var edge_index:int = -1;
			var targets:Array = this.getTargets();
			var sources:Array = this.getSources();
			for (var i:Number = 0; i<targets.length; i++){
				var source:NodeSprite = targets[i];
				var target:NodeSprite = targets[i];
				if (eq(source.name,source_name) && (eq(target.name,target_name))){
					edge_index = i;
					break;
				}
				else if (eq(source.name,source_name) && (eq(source.name,target_name))){
					edge_index = i;
					break;
				} 
			}	
			
			if (neq(edge_index,-1)){
				return this.data.edges[edge_index];
			}
			else {
				return null;
			}
				
		}
			
		//helper functions
		public function addNodeIfNotExist(name:String):NodeSprite
		{
			trace("adding" + name);
			var interactor:NodeSprite;
			if (!this.checkNode(name)){
					trace("create");
					interactor=this.addNode({name:name});
				}
			else{
					interactor=this.findNodeByName(name);
				}
			return interactor;
		}
		
		public function addAnnotation(geneName:String, annotationName:String):NodeSprite
		{
			var annotation:NodeSprite=this.addNode({name:geneName},"Annotations");
			var interactor:NodeSprite=this.findNodeByName(geneName);
			this.addEdgeIfNotExist(interactor, annotation);
			return annotation;
		}
		
//		public function addEdgeToAttribute(name:String):EdgeSprite
//		{
//			return null;
//		}
		
		private function getTargets():Array {
			var edges:Array = this.data.edges.toDataArray();
			return edges.map(extractTargets);
		}
		
		private function getSources():Array {
			var edges:Array = this.data.edges.toDataArray();
			return edges.map(extractSources);
		}
		
		private function extractNames(element:*, index:int, arr:Array):String {
            return String(element.data.name);
        }

		private function extractTargets(element:*, index:int, arr:Array):EdgeSprite {
            return element.target;
        }		

		private function extractSources(element:*, index:int, arr:Array):EdgeSprite {
            return element.source;
        }		

		//look for attribute as target and node as source
//		public function findAttributesByNode()
//		{
//			
//		}
//	
		public function toggleChanged()
		{
			this.changed = !this.changed;
		}	

//		
	}
}