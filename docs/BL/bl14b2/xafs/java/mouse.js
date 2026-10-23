// mouse over ‚É‚æ‚éF•ÏX

	var after = "#ffffff";
	var take = "#ECC";

	function mouseOver(obj){
	obj.style.backgroundColor = take;
	}
	function mouseOut(obj){
	obj.style.backgroundColor = after;
	}
	function clk(str){
	str = str.match(/href=\"(.+)\"/i);
	location.href=str[1];
	}
