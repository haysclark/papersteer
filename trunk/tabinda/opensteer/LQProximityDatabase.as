package tabinda.opensteer
{
	public class LQProximityDatabase extends AbstractProximityDatabase
	{

		var lq:locationQueryDatabase;

		// constructor
		public function LQProximityDatabase(center:Vector3,dimensions:Vector3,divisions:Vector3)
		{
			var halfsize:Vector3=dimensions * 0.5;
			var origin:Vector3=center - halfsize;


			lq=new locationQueryDatabase(origin.x,origin.y,origin.z,dimensions.x,dimensions.y,dimensions.z,int(Math.round(divisions.x)),int(Math.round(divisions.y)),int(Math.round(divisions.z)));
		}
	}
}