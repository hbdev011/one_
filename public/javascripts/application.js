// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function validateIP(evt) {

	evt = (evt) ? evt : window.event
	var charCode = (evt.which) ? evt.which : evt.keyCode

	if ((charCode >= 48 && charCode <= 57) || charCode == 46 || charCode == 37 || charCode == 39 || charCode == 8 || charCode == 9 ) {
		return true
	}
	return false
}

function numbersOnly(evt) {

	evt = (evt) ? evt : window.event
	var charCode = (evt.which) ? evt.which : evt.keyCode

	if ((charCode >= 48 && charCode <= 57) || charCode == 37 || charCode == 39 || charCode == 8 || charCode == 9 ) {
		return true
	}
	return false
}



function nospace(evt) {
	evt = (evt) ? evt : window.event
	var charCode = (evt.which) ? evt.which : evt.keyCode

	if (charCode != 32) {
		return true
	}
	return false
}

function CheckValidFile(val, id, name, format) {
	var a = val.substring(val.lastIndexOf('.') + 1).toLowerCase();
	if(a == format) {
		return true;
	}
	else {
		$("frm_upload").reset();
		alert('The extension ' + a.toUpperCase() + ' is not valid. Please Upload only ('+format+') Files!!!');
		return false;
	}
}

// ==================== Generate Truth Table Starts ====================
// sort variables alphabetically
//
function sortVariables()
{
	var i,j,k;
	for(i=0;i<vars.length-1;++i)
		for(j=i+1;j<vars.length;++j)
		{
			if(vars[i]>vars[j])
			{
				k=vars[i];
				vars[i]=vars[j];
				vars[j]=k;
			}
		}
}

// -1 if the letter is not a variable, otherwise variable number
//
function isVariable(let)
{
	var j;
	for(j=0;j<vars.length;++j) if(let==vars[j]) return(j);
	return(-1);
}

// compute logic data3 with no brackets and return the logic value
//
function compute(startpos,endpos)
{
	var j;
	data4=data3.substring(startpos,endpos+1);
	for(j=0;j<=data4.length;++j)
	{
		if (data4.charAt(j+1)=='`' || data4.charAt(j+1)=="'")
		{
			if(data4.charAt(j)=='1') k=0; else k=1;
			data4=data4.substring(0,j)+k+data4.substring(j+2);
			--j;
		}
	}
	for(j=0;j<=data4.length;++j)
	{
		if ((data4.charAt(j)=='0' || data4.charAt(j)=='1') && (data4.charAt(j+1)=='0' || data4.charAt(j+1)=='1'))
		{
			if(data4.charAt(j)=='1' && data4.charAt(j+1)=='1') k=1; else k=0;
			data4=data4.substring(0,j)+k+data4.substring(j+2);
			--j;
		}
		else if ((data4.charAt(j)=='0' || data4.charAt(j)=='1') && data4.charAt(j+1)=='^')
		{
			if(data4.charAt(j)==data4.charAt(j+2)) k=0; else k=1;
			data4=data4.substring(0,j)+k+data4.substring(j+3);
			--j;
		}
	}
	var k=0;
	for(j=0;j<=data4.length;++j) 	{
		if(data4.charAt(j)=='1') {k=1; break;}
	}
	return(k);
}

// main evaluation data
//
function evaluateMe(expr)
{
   vars.length=0;
	values.length=0;
	bracket.length=0;

	data=expr    //document.getElementById('expr').value;

	data2='';

	// parsing; level one: remove white spaces
	//
	for(i=0;i<data.length;++i)
	{
		if(data.charCodeAt(i)>32) data2+=data.charAt(i);
	}

	// parsing; level two: find all variables
	//
	for(i=0;i<data2.length;++i)
	{
		posvar=data2.charAt(i);
		if(posvar!='`' && posvar!="'" && posvar!='|' && posvar!='^' && posvar!='(' && posvar!=')')
		{
			// found an invalid character
			//
			if(posvar<'a' || posvar>'z')
			{
				return ('Parse error: invalid character', i);
			}

			// found a variable
			//
			for(j=0;j<vars.length;++j)
			{
				if(posvar==vars[j]) break;
			}
			if(j==vars.length) vars[j]=posvar;
		}
	}

	// parsing; level three: find parentheses and operands validity
	//
	parlevel=0; prev=0;
	for(i=0;i<data2.length;++i)
	{
		next=data2.charAt(i+1);
		posvar=data2.charAt(i);
		if (posvar=='|' && ((prev!=')' && prev!='`' && prev!="'" && isVariable(prev)<0) || ( next!='(' && isVariable(next)<0)))
		{
			// misplaced +
			//
			return ('Parse error: misplaced "+"',i);
		}
		if (posvar=='^' && ((prev!=')' && prev!='`' && prev!="'" && isVariable(prev)<0) || (next!='(' && isVariable(next)<0)))
		{
			// misplaced ^
			//
			return ('Parse error: misplaced "^"',i);
		}
		if((posvar=='`' || posvar=="'") && prev!=')' && prev!="'" && prev!='`' && isVariable(prev)<0)
		{
			// misplaced `
			//
			return ('Parse error: misplaced "'+"'"+'"',i);
		}
		if(posvar=='(') ++parlevel;
		if(posvar==')')
		{
			if(!parlevel)
			{
				// too many ')' brackets
				//
				return ('Parse error: parentheses mismatch',i);
			}
			--parlevel;
		}
		prev=posvar;
	}
	if(parlevel)
	{
		// to few ')' brackets
		//
		return ('Parse error: parentheses missing',-1);
	}
	if(posvar=='|')
	{
		// + at the end of input
		//
		return ('Parse error: misplaced "+"',i-1);
	}

	sortVariables();
	//$('logictable').innerHTML='Expression parsed successfully.. found '+vars.length+' variable'+(vars.length==1?'':'s')+'.';

	// evaluating the expression; swap 1's and 0's for letters
	//
	nosteps=(1<<vars.length);
	for(i=0;i<vars.length;++i) values[i]=0;

	k=0;
	s='';
	for(i=0;i<vars.length;++i) s+=vars[i]+" ";
	s+=",----------------------,"

	for(i=0;i<nosteps;++i)
	{
		// format output
		for(j=0;j<vars.length;++j) s+=values[j]+" ";
		s+="| "
		// replace letters by numbers
		//
		data3=data2;
		for(j=0;j<data3.length;++j) if((k=isVariable(data3.charAt(j)))!=-1) data3=data3.substring(0,j)+values[k]+data3.substring(j+1);

		// evaluate.. sweep along parentheses to find which values to evaluate first
		//
		bracketno=0;
		for(j=0;j<data3.length;++j)
		{
			if(data3.charAt(j)=='(') bracket[bracketno++]=j+1;
			if(data3.charAt(j)==')')
			{
				// found first occurrence of closed brackets.. i.e. all data within the brackets
				// has no internal brackets
				//
				k=compute(bracket[bracketno-1],j-1);
				data3=data3.substring(0,bracket[bracketno-1]-1)+k+data3.substring(j+1);
				j=bracket[bracketno-1]-1;
				--bracketno;
			}
		}
		k=compute(0,data3.length-1);
		s+=k+",";      //'</TD></TR>';
		j=vars.length-1;
		while(j>=0)
		{
			values[j]=1-values[j];
			if(values[j]) break;
			--j;
		}
	}

	return s;

}

// ==================== Generate Truth Table Ends ====================


function fetchQuelle(matrix,quelle,kreuzschieneId, sourceId) {
	jQuery.ajax({
		url : '/sources/fetch_quelle',
		method : 'get',
		data : {
			matrix : matrix,
			quelle : quelle,
			kreuzschiene_id : kreuzschieneId,
			source_id : sourceId
		}
	})
 // new Ajax.request("/source/fetch_quelle", {method : 'get',parameters : {matrix : matrix, quelle : quelle}})
}


var updateLabel = function(val){
  jQuery.ajax({
    url : '/family/save_label_values',
    data: {value: val},
    type: 'POST',
    success: function(data){
      jQuery("#msg").html("<b>" + data + "</b>")
    }
  });
}

var updateFont = function(val){
  jQuery.ajax({
    url : '/family/save_font_values',
    data: {value: val},
    type: 'POST',
    success: function(data){
      jQuery("#msg").html("<b>" + data + "</b>")
    }
  });
}

var deleteFamily = function(val){
  var value = val;
  jQuery.ajax({
    url : '/family/delete_family',
    data: {nummer: val},
    type: 'get',
    success: function(data){
      var res;
      if(data){
        res = confirm("Are you sure you want to delete this family? It is in use.")
      } else {
        res = confirm("Are you sure you want to delete this family?")
      }
      if(res == true){
        window.location = "/family/delete_family/" + value + "?&confirmed=true" ;
      }
    }
  });
}
