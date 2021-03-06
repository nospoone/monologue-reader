/**
 * Copyright (c) 2016 Level Up Labs, LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

package monologue;
using monologue.DynamicHelper;
using monologue.MonologueHelper;

/**
 * ...
 * @author 
 */
@:allow(monologue)
class MonologueTree
{
	public var ID(default, null):Int;
	public var categoryID:Int;
	public var displayName:String;
	public var nodes:Array<MonologueTreeNode>;
	
	public function new(){}
	
	public static function fromJSON(json:Dynamic):MonologueTree
	{
		var mt = new MonologueTree();
		
		var ID:Int = json.jsonVar("id","-1").toInt();
		var categoryID:Int = json.jsonVar("categoryId", "-1").toInt();
		var displayName:String = Std.string(json.jsonVar("displayName"));
		var nodes:Array<MonologueTreeNode> = json.jsonArray("nodes", function(arr:Array<Dynamic>){
			var ns:Array<MonologueTreeNode> = [];
			for (entry in arr)
			{
				var type = Std.string(entry.jsonVar("type")).toTreeNodeType();
				var mNode:MonologueTreeNode = switch(type)
				{
					case BRANCH: TreeNodeBranch.fromJSON(entry);
					case TEXT: TreeNodeText.fromJSON(entry);
					case SET: TreeNodeSet.fromJSON(entry);
					default: null;
				}
				
				if (mNode != null)
				{
					mNode.locFlag = "$T" + ID + "N" + mNode.ID;
					ns.push(mNode);
				}
			}
			return ns;
		});
		
		mt.ID = ID;
		mt.categoryID = categoryID;
		mt.displayName = displayName;
		mt.nodes = nodes;
		
		return mt;
	}
}

@:allow(monologue)
class MonologueTreeNode
{
	public var ID(default, null):Int=-1;
	public var type(default, null):TreeNodeType;
	public var link(default, null):Int =-1;
	public var locFlag(default, null):String="";
}

@:allow(monologue)
class TreeNodeText extends MonologueTreeNode
{
	public var name(default, null):String="";
	public var voice(default, null):String = "";
	
	public function new(){}
	
	public static function fromJSON(json:Dynamic):MonologueTreeNode
	{
		var node = new TreeNodeText();
		node.ID = json.jsonVar("id", "-1").toInt();
		node.type = Std.string(json.jsonVar("type")).toTreeNodeType();
		node.link = json.jsonVar("link", "-1").toInt();
		node.name = Std.string(json.jsonVar("name"));
		node.voice = Std.string(json.jsonVar("voice"));
		return node;
	}
}

@:allow(monologue)
class TreeNodeBranch extends MonologueTreeNode
{
	public var variable(default, null):Int = -1;
	public var value(default, null):Dynamic = null;
	public var condition(default, null):Condition=UNKNOWN;
	public var trueLink(default, null):Int=-1;
	public var falseLink(default, null):Int =-1;
	
	public function new(){}
	
	public static function fromJSON(json:Dynamic):MonologueTreeNode
	{
		var node = new TreeNodeBranch();
		node.ID = json.jsonVar("id", "-1").toInt();
		node.type = Std.string(json.jsonVar("type")).toTreeNodeType();
		node.link = json.jsonVar("link", "-1").toInt();
		node.variable = json.jsonVar("variable","-1").toInt();
		node.value = json.jsonVar("value","");
		node.condition = Std.string(json.jsonVar("condition")).toCondition();
		node.trueLink = json.jsonVar("trueLink", "-1").toInt();
		node.falseLink = json.jsonVar("falseLink", "-1").toInt();
		return node;
	}
}

@:allow(monologue)
class TreeNodeSet extends MonologueTreeNode
{
	public var variable(default, null):Int = -1;
	public var operation(default, null):Operator=UNKNOWN;
	public var value(default, null):String = "";
	
	public function new(){}
	
	public static function fromJSON(json:Dynamic):MonologueTreeNode
	{
		var node = new TreeNodeSet();
		node.ID = json.jsonVar("id", "-1").toInt();
		node.type = Std.string(json.jsonVar("type")).toTreeNodeType();
		node.link = json.jsonVar("link", "-1").toInt();
		node.variable = json.jsonVar("variable").toInt();
		node.operation = Std.string(json.jsonVar("operation")).toOperator();
		node.value = Std.string(json.jsonVar("value", ""));
		return node;
	}
}

enum TreeNodeType
{
	BRANCH;
	SET;
	TEXT;
	CUSTOM;
	UNKNOWN;
}

enum Operator
{
	SET;
	INCREMENT;
	DECREMENT;
	UNKNOWN;
}

enum Condition
{
	EQUAL;
	NOT_EQUAL;
	LESS_THAN;
	GREATER_THAN;
	LESS_THAN_EQUAL;
	GREATER_THAN_EQUAL;
	UNKNOWN;
}