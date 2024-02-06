package hrt.prefab.fx;


@:access(hrt.prefab.fx.LookAt)
class BillboardObject extends h3d.scene.Object {
	var graphics:h3d.scene.Graphics;
	public var LockX: Bool;
	public var LockY: Bool;
	public var LockZ: Bool;
	public var initFwd: h3d.Vector;
	static var tmpMat = new h3d.Matrix();
	static var tmpVec = new h3d.Vector();

	override function syncRec(ctx) {
		posChanged = true;
		super.syncRec(ctx);
	}

	override function calcAbsPos() {
		super.calcAbsPos();

		var camera = getScene().camera;
		if (camera == null)
			return;

		tmpMat.load(absPos);

		var xRot = qRot;

		var fwd = tmpVec;
		fwd.load(camera.target.sub(camera.pos));
		fwd.normalize();

		var curFwd = getLocalDirection();
		curFwd.normalize();
		if (LockX)
			fwd.x = initFwd.x;
		if (LockY)
			fwd.y = initFwd.y;
		if (LockZ)
			fwd.z = initFwd.z;

		qRot.initDirection(fwd, camera.up);

		absPos.tx = tmpMat.tx;
		absPos.ty = tmpMat.ty;
		absPos.tz = tmpMat.tz;
	}
}

@:allow(hrt.prefab.fx.Billboard.BillboardInstance)
class Billboard extends Object3D {
	@:s public var LockX: Bool;
	@:s public var LockY: Bool;
	@:s public var LockZ: Bool;

	override function makeObject(parent3d: h3d.scene.Object) {
		var billboard = new BillboardObject(parent3d);
		billboard.initFwd = billboard.getLocalDirection();
		billboard.initFwd.normalize();
		return billboard;
	}

	override function updateInstance(?propName : String) {
		super.updateInstance();

		var billboard = Std.downcast(local3d, BillboardObject);
		billboard.LockX = this.LockX;
		billboard.LockY = this.LockY;
		billboard.LockZ = this.LockZ;
	}

	#if editor
	override function getHideProps():hide.prefab.HideProps {
		return {
			icon: "cog",
			name: "Billboard"
		};
	}

	override function edit( ctx : hide.prefab.EditContext ) {
		super.edit(ctx);

		var el = new hide.Element('<div class="group" name="Color Mask">
		<dt>Axis constraints</dt>
			<dd>
				X <input type="checkbox" field="LockX" class="LockX"/>
				Y <input type="checkbox" field="LockY" class="LockY"/>
				Z <input type="checkbox" field="LockZ" class="LockZ"/>
			</dd>
		</div>');

		ctx.properties.add(el, this, function(pname) {
			this.updateInstance();
		});
	}
	#end

	static var _ = Prefab.register("billboard", Billboard);
}