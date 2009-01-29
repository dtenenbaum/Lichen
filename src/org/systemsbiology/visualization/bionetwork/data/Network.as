package org.systemsbiology.visualization.bionetwork.data
{
	import flare.query.methods.*;
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
			
			
		}
		
		//add node if doesn't already exist; if exist return dedge
		public function addNode(n:Object):NodeSprite
		
		{
			return this.data.addNode(n);
		}
		
		//add edge if doesn't already exist; if exist returns node
		public function addEdgeIfNotExist(source:NodeSprite, target:NodeSprite, directed:Object = false):EdgeSprite
		{
			if (!checkEdge(source.name, target.name,directed)){
				return this.data.addEdgeFor(source, target);
			}
			else {
				return this.findEdgeByNodes(source.name,target.name);
			}
			
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
		
		public function updateNodeParams(name:String, params:Object):void{
			//add params 
			var node:NodeSprite=this.findNodeByName(name);
			for(var param in params){
				this.data.nodes.setProperty("props."+param, params[param], null, function(n:NodeSprite):Boolean{return n.data.name=="11127";});				
			}
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
			
//		
		//helper functions
		
		public function addNodeIfNotExist(name:String):NodeSprite
		{
			trace("adding" + name);
			var interactor:NodeSprite;
			if (!this.checkNode(name)){
					trace("create");
					interactor=this.data.addNode({name:name});
				}
			else{
					interactor=this.findNodeByName(name);
				}
			return interactor;
		}
		
		public function addAttribute(name:String):NodeSprite
		{
			return null;
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