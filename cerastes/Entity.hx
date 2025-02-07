package cerastes;

import cerastes.c2d.DebugDraw;
import cerastes.macros.Metrics;
#if network
import cerastes.net.Replicated;
#end
import cerastes.Utils.*;
using cerastes.types.List;

typedef ScheduledFunction = {
	var time: Float;
	var func: Void->Void;
}

@:keep
class EntityManager
{
	public static var instance(default, null):EntityManager = new EntityManager();

	public var entities = new Array<Entity>();

	static var lastId = 0;

	var scheduledFunctions: List<ScheduledFunction> = new List<ScheduledFunction>();

	public function new () {}

	public function tick( delta: Float )
	{
		Metrics.begin();

		var i = entities.length;

		while( i-- > 0 )
		{
			if( entities[i].isDestroyed() )
				entities.splice(i,1);
			else if( entities[i].initialized )
				entities[i].tick(delta);
		}

		var t = haxe.Timer.stamp();
		while( scheduledFunctions.first() != null && scheduledFunctions.first().item.time < t )
		{
			var f = scheduledFunctions.pop().item;
			f.func();
		}

		Metrics.end();
	}

	public function register( t : Entity )
	{
		entities.push(t);
	}

	public function find( id: String )
	{
		for( e in entities )
		{
			if( e.lookupId == id )
				return e;
		}

		return null;
	}

	public static function getId()
	{
		return ++lastId;
	}

	function scheduleInsertFunc( item: ScheduledFunction, other: ScheduledFunction ) : Bool
	{
		return item.time < other.time;
	}

	public function schedule(time: Float, func: Void->Void )
	{
		var low = 0;
		var high = scheduledFunctions.length;

		var sf : ScheduledFunction = {
			time: time + haxe.Timer.stamp(),
			func: func
		};

		scheduledFunctions.insert(sf, scheduleInsertFunc );
		/*
		while (low < high)
		{
			var mid = (low + high) >>> 1;
			if (scheduledFunctions[mid].time < sf.time)
				low = mid + 1;
			else
				high = mid;
		}
		scheduledFunctions.insert(low, sf);
		*/


	}

}



interface Entity {

	public var lookupId: String;

	public var initialized(get, never): Bool;

	public function tick( delta: Float ): Void;
	public function destroy(): Void;

	// Whether or not this entity is "alive". This is not about HP
	public function isDestroyed(): Bool;
}

@:keep
class BaseEntity #if network implements Replicated #end implements Entity
{
	// used by the client to find entities
	public var lookupId: String = "";

	public var initialized(get, never): Bool;

	function get_initialized()
	{
		return true;
	}

	#if network
	//@:noCompletion public var _repl_netid : UI16 = -1;


	#if server
	public function new()
	{
		EntityManager.instance.register(this);
		_repl_netid = EntityManager.getId();
	}
	#end

	#if client
	public function new(  )
	{
		EntityManager.instance.register(this);
	}
	#end




	// Called after first-time replication is complete (ie, after constructor and first full sync )
	public function replicated( )
	{
		info("Replicated a " + this);
	}

	#end


	public function destroy()
	{
	}

	public function tick( delta: Float )
	{
	}

	function schedule(time: Float, func: Void->Void )
	{
		EntityManager.instance.schedule( haxe.Timer.stamp() + time, func );
	}

	public function isDestroyed()
	{
		return false;
	}

	public function toString(): String
	{
		#if network
		return '${Type.getClassName(Type.getClass(this))}-${StringTools.hex( _repl_netid )}';
		#else
		return '${Type.getClassName(Type.getClass(this))}';
		#end
	}
}