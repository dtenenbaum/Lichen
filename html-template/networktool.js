    DEBUG=1;
    function log(message){
    	
    	if (DEBUG){
    		console.log(message);
    	}
    }
    
        function trace(){
    	if (DEBUG){
    		console.trace();
    	}
    }
    
    function sprout(node_id){
          log("sprouting");
          log(node_id);
  		  url = 'http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;';
  		  log('URL: ' + url);
	  	  update_query = new google.visualization.Query('http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;');
	  	  log("update query");
	  	  log(update_query);
	  	  center=node_id;
	  	  update_query.send(processUpdate, true);
	  	}
      
     function fetch_urls(urls, isAnUpdate){
     	log("fetch urls");
      	//reqId=0;
      	cnt=0;
      	options = new Object;
		number_urls=0;
		if (typeof(isAnUpdate)=="undefined"){
			console.log("update is false");
			update=false;
		}
		else {
			console.log("update is true");
			update=true;
		}
	    	
		//set config
		center='23645';
		queries=[];
		funcs=[];
		reqId=0;
		for (var i in urls) {
			log("key " + i);
			url = eval('urls.' + i);
			if (i==='dataurl'){
				func = processData;
				query_url = url+'?tqx=reqId:'+reqId+';&format=google';
				number_urls+=1;
				funcs.push(func);
				queries.push(new google.visualization.Query(query_url));
			}
			else if (i==='attributeurl'){
				func=processAttributes;
			}
			else if (i==='layouturl'){
				func=processLayout;
				query_url = url+'&tqx=reqId:'+reqId+';&format=google';
				log(query_url);
				number_urls+=1;
				funcs.push(func);
				queries.push(new google.visualization.Query(query_url));
			}
			//everything else goes in the options object to be passed via draw_vis()
			else{
				options[i] = urls[i];
			}
			//if (i in {'dataurl':'', 'attributeurl':'', 'layouturl':''}){
				//log("url " + query_url);	
				//query=new google.visualization.Query(query_url);
				//query.send(func);
				//query.setTimeout(300);
				//reqId+=1;
			//}
		
		}
		for (i=0; i<queries.length; i++){
			log("sending query # " + i);
			queries[i].send(funcs[i]);
		} 	
      }

	function draw_vis(){
		log("draw_visualization");
		networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
		//(data, options)
       	//networkvis.draw(data, {layout:layout_data, center:center, data_format:"google"});
       	if (update==false){
       		log("draw");
    		networkvis.draw(data, options);
       	}
       	else {
       		log("redraw");
       		network.redraw(data, options);
       	}
       	//networkvis.draw(data, {center:center, data_format:"google"});
	}
	  	
	 function processLayout(response){
	 	//layout_data='';
	 	log("processLayout");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		}
		log("layout response:");
		log(response);
		layout_data = null;
		layout_data = response.getDataTable();
		
		while(true){
			if (!(layout_data===null)){
				options['layout_data']=layout_data;
				log("break2");
				cnt+=1;
				break;
			}
		}
		
		log("count: "+ cnt);
		if (cnt===number_urls){
			draw_vis();
		}
	 } 	
	 
	 function processData(response){
	 	log("processData");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		}
		data = null;
		data = response.getDataTable();
		while(true){
			if (!(data===null)){
				log("break1");
				cnt+=1;
				break;
			} 
		 }
	
		log("count: " + cnt);
		if (cnt===number_urls){
			draw_vis();
		}
	 }
	 
	 function processAttributes(response){
	 	log("processAttributes");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());	
		}
	 	attribute_data = response.getDataTable();
	 	cnt+=1;
	 }
	  	
// function processDataAndLayout(response){
// 	  // alert("processResponse");
// 		if (response.isError()) {
// 			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
// 			return;
// 		}
// 		data = response.getDataTable();
// 		//query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/Attribute/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+center+'/&tqx=reqId:1;');
// 		query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/layout/random/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+23645+'/&tqx=reqId:1;');
// 		query2.setTimeout(300);
// 		query2.send(processLayoutData);	
// 		//networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
// 		//log("vis: " + networkvis.toString());
// }
// 
// function processLayoutData(response){
// 	
// 	log("process layout data");
//    log("response");
//    log(response);
//  	if (response.isError()) {
// 		alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
// 		return;
// 	}
// 	
//   log("layout response");
//   layout_data=response.getDataTable();
//   //attribute_data=Object.toJSON(response.getDataTable());
//   //attribute_data =  buildDataParam(response.getDataTable());
//   log("serialized attribute data" + layout_data);
//   networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
//   networkvis.draw(data, {layout: layout_data, center:center, data_format:"google"});
// }
	 
	   function buildDataParam(dataTable){
 		log("buildDataParam");
 		log(dataTable);
		//log(!this.isEmpty(dataTable));
		if (!this.isEmpty(dataTable)){
		//if (true){
    	var dataParam = {cols:[], rows:[]};
    	log("Num columns");
    	log(dataTable.getNumberOfColumns());
    	for (var coli=0;coli<dataTable.getNumberOfColumns();coli++){
			dataParam.cols[coli]={id: dataTable.getColumnId(coli), label: dataTable.getColumnLabel(coli), type: 'string'};
			for (var rowi=0;rowi<dataTable.getNumberOfRows();rowi++){
				dataParam.rows[rowi]={};
				dataParam.rows[rowi].c=[];
				for (var coli=0;coli<dataTable.getNumberOfColumns();coli++){
					//will need to add any aditional paramters used here
					dataParam.rows[rowi].c[coli]={v:dataTable.getValue(rowi,coli)};
					if(dataTable.getFormattedValue(rowi,coli)){
						dataParam.rows[rowi].c[coli].f=dataTable.getFormattedValue(rowi,coli);
					}
				}
			}
		}
    }
    	//log(dump(dataParam));
    	return dataParam;
    }
	 
    function isEmpty(object) {
		for (var i in object) { return false; }
		return true;
	}  
	 
	function dump(arr,level) {
	var dumped_text = "";
	if(!level) level = 0;
	
	//The padding given at the beginning of the line.
	var level_padding = "";
	for(var j=0;j<level+1;j++) level_padding += "    ";
	
	if(typeof(arr) == 'object') { //Array/Hashes/Objects 
		for(var item in arr) {
			var value = arr[item];
			
			if(typeof(value) == 'object') { //If it is an array,
				dumped_text += level_padding + "'" + item + "' ...\n";
				dumped_text += dump(value,level+1);
			} else {
				dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
			}
		}
	} else { //Stings/Chars/Numbers etc.
		dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
	}
	return dumped_text;
}
	