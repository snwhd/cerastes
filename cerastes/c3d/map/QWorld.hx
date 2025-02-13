
package cerastes.c3d;

import cerastes.c3d.QEntity.QEntityManager;
import cerastes.c3d.map.QMap;
#if bullet
import bullet.Native;
import bullet.Shape;
#end
import h3d.Matrix;
import cerastes.file.CDParser;
import cerastes.file.CDPrinter;
import cerastes.c3d.Prefab.PrefabDef;
import h3d.Vector;
import h3d.Quat;
import h3d.scene.World;
import h3d.scene.Object;

class QWorld extends World
{
	#if bullet
	public var physics: BulletWorld;
	#end

	var map: QMap;

	public static final QU_TO_METERS = 1.7 / 64;
	public static final METERS_TO_QU = 64 / 1.7;

/*
	public function loadMap(file: String)
	{
		map = new cerastes.c3d.map.QMap(file, this, this);
		map.init();
	}

*/


}