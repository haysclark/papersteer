package tabinda.opensteer
{
	// Class used to store each list of clients
	public class lqBin
	{
		public var clientList:Array;
		public var center:Vector3;

		public function lqBin(binCenter:Vector3)
		{
			clientList=new Array();//<lqClientProxy>();
			center=binCenter;
		}
	}
}