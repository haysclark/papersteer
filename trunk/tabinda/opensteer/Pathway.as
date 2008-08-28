package tabinda.opensteer
{
	public class Pathway
	{
		// Given an arbitrary point ("A"), returns the nearest point ("P") on
		// this path.  Also returns, via output arguments, the path tangent at
		// P and a measure of how far A is outside the Pathway's "tube".  Note
		// that a negative distance indicates A is inside the Pathway.
		public function mapPointToPath(point:Vector3,tStruct:mapReturnStruct):Vector3
		{
			return Vector3.ZERO;
		}
		//public virtual Vector3 mapPointToPath(Vector3 point, Vector3 tangent, float outside) { return Vector3.ZERO; }


		// given a distance along the path, convert it to a point on the path
		public function mapPathDistanceToPoint(pathDistance:Number):Vector3
		{
			return Vector3.ZERO;
		}

		// Given an arbitrary point, convert it to a distance along the path.
		public function mapPointToPathDistance(point:Vector3)
		{
			return 0;
		}

		// is the given point inside the path tube?
		public function isInsidePath(point:Vector3):Boolean
		{

			//float outside;
			//Vector3 tangent;
			var tStruct:mapReturnStruct=new mapReturnStruct  ;

			mapPointToPath(point,tStruct);//tangent, outside);
			return tStruct.outside < 0;
		}

		// how far outside path tube is the given point?  (negative is inside)
		public function howFarOutsidePath(point:Vector3):Number
		{
			//float outside;
			//Vector3 tangent;
			var tStruct:mapReturnStruct=new mapReturnStruct  ;

			mapPointToPath(point,tStruct);//tangent, outside);
			return tStruct.outside;
		}
	}
}